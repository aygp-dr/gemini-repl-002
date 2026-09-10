(ns gemini-repl.specs
  "Data specs for gemini-repl (https://clojure.org/guides/spec).
  Function specs (s/fdef) live next to each defn in gemini-repl.core."
  (:require [clojure.spec.alpha :as s]))

;; --- Configuration (gemini-repl.core/config) ---

(s/def :gemini-repl.config/api-key string?)
(s/def :gemini-repl.config/api-url string?)
(s/def :gemini-repl.config/model string?)
(s/def :gemini-repl.config/log-enabled boolean?)
(s/def :gemini-repl.config/log-file string?)
(s/def :gemini-repl.config/log-fifo string?)
(s/def ::config
  (s/keys :req-un [:gemini-repl.config/api-key :gemini-repl.config/api-url
                   :gemini-repl.config/model :gemini-repl.config/log-enabled
                   :gemini-repl.config/log-file :gemini-repl.config/log-fifo]))

;; --- REPL commands ---

(def commands
  "Slash commands handled by gemini-repl.core/process-input."
  #{"/help" "/exit" "/clear" "/stats" "/context" "/debug"})

(s/def ::command commands)

;; Any (trimmed) line typed at the prompt.
(s/def ::input string?)

;; --- Conversation history (Gemini "contents" wire format, as clj maps) ---

(s/def :gemini-repl.part/text string?)
(s/def ::part (s/keys :req-un [:gemini-repl.part/text]))
(s/def ::parts (s/coll-of ::part :kind vector? :min-count 1 :gen-max 3))
(s/def ::role #{"user" "model"})
(s/def ::message (s/keys :req-un [::role ::parts]))
(s/def ::history (s/coll-of ::message :kind vector? :gen-max 8))

;; --- API response, as parsed by js->clj :keywordize-keys true ---

(s/def :gemini-repl.usage/totalTokenCount nat-int?)
(s/def :gemini-repl.response/usageMetadata
  (s/keys :opt-un [:gemini-repl.usage/totalTokenCount]))
(s/def :gemini-repl.candidate/content ::message)
(s/def ::candidate (s/keys :req-un [:gemini-repl.candidate/content]))
(s/def :gemini-repl.response/candidates (s/coll-of ::candidate :kind vector? :gen-max 2))
(s/def ::response-data
  (s/keys :opt-un [:gemini-repl.response/usageMetadata
                   :gemini-repl.response/candidates]))

(s/def ::duration-ms nat-int?)

;; The usage line printed after each answer, e.g. "[🟢 245 tokens | $0.0001 | 0.8s]"
(s/def ::metadata-line
  (s/and string?
         #(re-matches #"\[(🟢|🟡|🔴) \d+ tokens \| \$\d+\.\d{4} \| \d+(ms|\.\ds)\]" %)))

;; --- Session stats (gemini-repl.core/stats) ---

(s/def :gemini-repl.stats/total-tokens nat-int?)
(s/def :gemini-repl.stats/total-cost (s/double-in :min 0 :infinite? false :NaN? false))
(s/def :gemini-repl.stats/request-count nat-int?)
(s/def ::stats
  (s/keys :req-un [:gemini-repl.stats/total-tokens :gemini-repl.stats/total-cost
                   :gemini-repl.stats/request-count]))

;; --- Log entries (log-entry / log-to-fifo / log-to-file) ---

(s/def ::log-type #{"request" "response" "error"})
;; e.g. {:prompt "hi" :history-length 1}, {:status 200 :duration-ms 812 :tokens nil}
(s/def ::log-data
  (s/map-of simple-keyword? (s/nilable (s/or :string string? :number number?))
            :gen-max 4))
(s/def :gemini-repl.log/timestamp string?)
(s/def :gemini-repl.log/type ::log-type)
(s/def :gemini-repl.log/data ::log-data)
(s/def ::log-entry
  (s/keys :req-un [:gemini-repl.log/timestamp :gemini-repl.log/type :gemini-repl.log/data]))
