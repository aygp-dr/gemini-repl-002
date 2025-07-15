(ns gemini-repl.core
  (:require [clojure.string :as str]
            ["fs" :as fs]
            ["path" :as path]
            ["readline" :as readline]
            ["https" :as https]))

;; State management
(def conversation-history (atom []))
(def stats (atom {:total-tokens 0
                  :total-cost 0.0
                  :request-count 0}))

;; Configuration
(def config
  {:api-key (or js/process.env.GEMINI_API_KEY "")
   :api-url "generativelanguage.googleapis.com"
   :model "gemini-pro"
   :log-enabled (= js/process.env.GEMINI_LOG_ENABLED "true")
   :log-file (or js/process.env.GEMINI_LOG_FILE "logs/gemini-repl.log")
   :log-fifo (or js/process.env.GEMINI_LOG_FIFO "/tmp/gemini-repl.fifo")})

;; Logging functions
(defn log-to-fifo [entry]
  (when (:log-enabled config)
    (try
      (fs/appendFileSync (:log-fifo config)
                         (str (.stringify js/JSON (clj->js entry)) "\n"))
      (catch js/Error _e
        ;; Silently ignore FIFO errors
        nil))))

(defn log-to-file [entry]
  (when (:log-enabled config)
    (let [log-dir (path/dirname (:log-file config))]
      (when-not (fs/existsSync log-dir)
        (fs/mkdirSync log-dir #js {:recursive true}))
      (fs/appendFileSync (:log-file config)
                         (str (.stringify js/JSON (clj->js entry)) "\n")))))

(defn log-entry [type data]
  (let [entry {:timestamp (.toISOString (js/Date.))
               :type type
               :data data}]
    (log-to-fifo entry)
    (log-to-file entry)))

;; Display banner
(defn display-banner []
  (try
    (let [banner-path "resources/repl-banner.txt"]
      (if (fs/existsSync banner-path)
        (println (fs/readFileSync banner-path "utf8"))
        (println "=== Gemini REPL ===")))
    (catch js/Error _e
      (println "=== Gemini REPL ===")))
  (println "Type /help for commands or your message to chat")
  (println))

;; Format response metadata
(defn format-metadata [response-data duration-ms]
  (let [tokens (or (get-in response-data [:usageMetadata :totalTokenCount]) 0)
        cost (* tokens 0.0000005) ;; Rough estimate
        duration (if (< duration-ms 1000)
                   (str duration-ms "ms")
                   (str (.toFixed (/ duration-ms 1000) 1) "s"))
        confidence (cond
                     (< tokens 100) "🟢"
                     (< tokens 500) "🟡"
                     :else "🔴")]
    (str "[" confidence " " tokens " tokens | $" (.toFixed cost 4) " | " duration "]")))

;; API request handling
(defn make-request [prompt callback]
  (let [start-time (.now js/Date)
        api-key (:api-key config)
        messages (conj @conversation-history
                       {:role "user" :parts [{:text prompt}]})
        request-data {:contents messages}]

    ;; Update conversation history
    (swap! conversation-history conj {:role "user" :parts [{:text prompt}]})

    ;; Log request
    (log-entry "request" {:prompt prompt :history-length (count messages)})

    (let [data (.stringify js/JSON (clj->js request-data))
          options #js {:hostname (:api-url config)
                       :path (str "/v1beta/models/" (:model config) ":generateContent?key=" api-key)
                       :method "POST"
                       :headers #js {"Content-Type" "application/json"
                                     "Content-Length" (.-length data)}}]

      (let [req (.request https options
                          (fn [res]
                            (let [chunks (atom [])]
                              (.on res "data" (fn [chunk]
                                                (swap! chunks conj chunk)))
                              (.on res "end" (fn []
                                               (try
                                                 (let [body (.toString (.concat js/Buffer (clj->js @chunks)))
                                                       response-data (js->clj (.parse js/JSON body) :keywordize-keys true)
                                                       duration-ms (- (.now js/Date) start-time)]

                                                   (log-entry "response" {:status (.-statusCode res)
                                                                          :duration-ms duration-ms
                                                                          :tokens (get-in response-data [:usageMetadata :totalTokenCount])})

                                                   (if (= (.-statusCode res) 200)
                                                     (let [content (get-in response-data [:candidates 0 :content :parts 0 :text])
                                                           metadata (format-metadata response-data duration-ms)]
                                                       ;; Update conversation history with response
                                                       (swap! conversation-history conj {:role "model" :parts [{:text content}]})
                                                       ;; Update stats
                                                       (swap! stats update :total-tokens + (or (get-in response-data [:usageMetadata :totalTokenCount]) 0))
                                                       (swap! stats update :total-cost + (* (or (get-in response-data [:usageMetadata :totalTokenCount]) 0) 0.0000005))
                                                       (swap! stats update :request-count inc)
                                                       (callback nil {:content content :metadata metadata}))
                                                     (callback (str "API Error: " (.-statusCode res) " - " body) nil)))
                                                 (catch js/Error e
                                                   (callback (str "Error parsing response: " (.-message e)) nil))))))))]
        (.on req "error" (fn [e]
                           (log-entry "error" {:message (.-message e)})
                           (callback (str "Request error: " (.-message e)) nil)))
        (.write req data)
        (.end req)))))

;; Command handlers
(defn handle-help []
  (println "\nAvailable commands:")
  (println "  /help    - Show this help message")
  (println "  /exit    - Exit the REPL")
  (println "  /clear   - Clear conversation history")
  (println "  /stats   - Show usage statistics")
  (println "  /context - Show current conversation")
  (println "  /debug   - Toggle debug logging")
  (println "\nType anything else to chat with Gemini"))

(defn handle-stats []
  (println "\nUsage Statistics:")
  (println (str "  Total requests: " (:request-count @stats)))
  (println (str "  Total tokens: " (:total-tokens @stats)))
  (println (str "  Estimated cost: $" (.toFixed (:total-cost @stats) 4))))

(defn handle-context []
  (println "\nConversation History:")
  (doseq [[idx msg] (map-indexed vector @conversation-history)]
    (println (str (inc idx) ". [" (:role msg) "] "
                  (-> msg :parts first :text (subs 0 (min 50 (count (-> msg :parts first :text)))))
                  (when (> (count (-> msg :parts first :text)) 50) "...")))))

(defn handle-debug []
  (let [new-state (not (:log-enabled config))]
    (set! config (assoc config :log-enabled new-state))
    (println (str "\nDebug logging " (if new-state "enabled" "disabled")))))

(defn handle-clear []
  (reset! conversation-history [])
  (println "\nConversation history cleared"))

;; Main REPL loop
(defn process-input [input rl]
  (cond
    (= input "/exit") (.close rl)
    (= input "/help") (do (handle-help) (.prompt rl))
    (= input "/clear") (do (handle-clear) (.prompt rl))
    (= input "/stats") (do (handle-stats) (.prompt rl))
    (= input "/context") (do (handle-context) (.prompt rl))
    (= input "/debug") (do (handle-debug) (.prompt rl))
    (str/blank? input) (.prompt rl)
    :else
    (do
      (make-request input
                    (fn [err response]
                      (if err
                        (println (str "\nError: " err))
                        (do
                          (println (str "\n" (:content response)))
                          (println (:metadata response))))
                      (println)
                      (.prompt rl))))))

(defn main []
  (display-banner)

  (when (str/blank? (:api-key config))
    (println "Warning: GEMINI_API_KEY not set in environment")
    (println "Set it in your .env file or export GEMINI_API_KEY=your-key-here")
    (println))

  (let [rl (.createInterface readline
                             #js {:input js/process.stdin
                                  :output js/process.stdout
                                  :prompt "gemini> "})]
    (.prompt rl)
    (.on rl "line" (fn [input]
                     (process-input (str/trim input) rl)))
    (.on rl "close" (fn []
                      (println "\nGoodbye!")
                      (.exit js/process 0)))))

;; Enable main function call
(set! *main-cli-fn* main)
