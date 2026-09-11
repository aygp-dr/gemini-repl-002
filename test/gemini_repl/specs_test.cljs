(ns gemini-repl.specs-test
  "Generative checks for every pure s/fdef'd fn, plus data-spec sanity.
  Per https://clojure.org/guides/spec (Testing). No test here touches the
  network: make-request and everything that calls it are never invoked."
  (:require [cljs.test :refer [deftest is testing]]
            [clojure.set :as set]
            [clojure.spec.alpha :as s]
            [clojure.spec.test.alpha :as stest]
            [clojure.string :as str]
            [clojure.test.check]
            [clojure.test.check.clojure-test :refer [defspec]]
            [clojure.test.check.properties :as prop]
            [gemini-repl.core :as core]
            [gemini-repl.specs :as specs]))

(def ^:private check-opts {:clojure.spec.test.check/opts {:num-tests 50}})

;; Side-effecting fns: fdef'd for instrumentation, never generatively checked.
(def ^:private side-effecting
  `#{core/log-to-fifo core/log-to-file core/log-entry            ; file/FIFO writes
     core/display-banner core/handle-help core/handle-stats      ; print
     core/handle-context core/handle-debug core/handle-clear     ; print; debug/clear mutate (see below)
     core/make-request core/process-input core/main})            ; HTTPS to the Gemini API / readline

(defn- fdefd []
  (set (filter s/get-spec (stest/enumerate-namespace 'gemini-repl.core))))

;; cljs stest/check is a macro, so the checked fns are listed literally; the
;; last assertion keeps this list in sync with the fdefs in core.
(deftest fdefs-hold-under-generative-testing
  (let [results (stest/check `[core/format-metadata] check-opts)]
    (is (seq results) "expected at least one fdef'd fn to check")
    (doseq [r results]
      (testing (str (:sym r))
        (is (nil? (:failure r))
            (pr-str (stest/abbrev-result r)))))
    (is (= (set/difference (fdefd) side-effecting) (set (map :sym results)))
        "every fdef in core is either checked or listed as side-effecting")))

(deftest data-specs-generate-and-conform
  (doseq [k [::specs/config ::specs/command ::specs/message ::specs/history
             ::specs/response-data ::specs/stats ::specs/log-entry]]
    (testing (str k)
      (is (every? (fn [[v _]] (s/valid? k v)) (s/exercise k 10))))))

(defn- context-lines [out]
  (keep #(re-matches #"(\d+)\. \[(user|model)\] (.*)" %) (str/split-lines out)))

;; History formatting and state: /context prints one numbered line per turn,
;; in order, with the text cut to 50 chars plus "..."; /clear then empties
;; the history. Runs against a scratch history and restores it afterwards.
(defspec context-lists-history-and-clear-empties-it 50
  (prop/for-all [history (s/gen ::specs/history)]
                (let [saved @core/conversation-history
                      shown (fn [{[{:keys [text]}] :parts}]
                              (if (> (count text) 50) (str (subs text 0 50) "...") text))]
                  (try
                    (reset! core/conversation-history history)
                    (let [lines (context-lines (with-out-str (core/handle-context)))]
                      (with-out-str (core/handle-clear))
                      (and (= (map str (range 1 (inc (count history)))) (map second lines))
                           (= (map :role history) (map #(nth % 2) lines))
                           (= (map shown history) (map #(nth % 3) lines))
                           (= [] @core/conversation-history)))
                    (finally (reset! core/conversation-history saved))))))

(deftest debug-toggles-logging
  (let [before (:log-enabled core/config)]
    (try
      (with-out-str (core/handle-debug))
      (is (= (not before) (:log-enabled core/config)))
      (is (s/valid? ::specs/config core/config))
      (finally
        (when (not= before (:log-enabled core/config))
          (with-out-str (core/handle-debug)))))
    (is (= before (:log-enabled core/config)))))

(deftest real-values-conform
  (testing "configuration and initial stats"
    (is (s/valid? ::specs/config core/config))
    (is (s/valid? ::specs/stats {:total-tokens 0 :total-cost 0.0 :request-count 0})))
  (testing "the core_test response fixture and its usage line"
    (let [response-data {:usageMetadata {:totalTokenCount 100}}]
      (is (s/valid? ::specs/response-data response-data))
      (is (s/valid? ::specs/metadata-line (core/format-metadata response-data 500)))))
  (testing "the README example usage line"
    (is (s/valid? ::specs/metadata-line "[🟢 245 tokens | $0.0001 | 0.8s]")))
  (testing "conversation_test messages"
    (is (s/valid? ::specs/history [{:role "user" :parts [{:text "Hello"}]}
                                   {:role "model" :parts [{:text "Hi there!"}]}])))
  (testing "log entries as make-request builds them"
    (is (s/valid? ::specs/log-data {:prompt "hi" :history-length 1}))
    (is (s/valid? ::specs/log-data {:status 200 :duration-ms 812 :tokens nil})))
  (testing "handle-help commands"
    (is (every? #(s/valid? ::specs/command %)
                ["/help" "/exit" "/clear" "/stats" "/context" "/debug"]))))
