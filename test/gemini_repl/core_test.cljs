(ns gemini-repl.core-test
  (:require [cljs.test :refer-macros [deftest is testing]]
            [gemini-repl.core :as core]))

(deftest test-format-metadata
  (testing "Format metadata with short duration"
    (let [response-data {:usageMetadata {:totalTokenCount 100}}
          result (core/format-metadata response-data 500)]
      (is (re-find #"🟢" result))
      (is (re-find #"100 tokens" result))
      (is (re-find #"500ms" result))))

  (testing "Format metadata with long duration"
    (let [response-data {:usageMetadata {:totalTokenCount 600}}
          result (core/format-metadata response-data 2500)]
      (is (re-find #"🔴" result))
      (is (re-find #"600 tokens" result))
      (is (re-find #"2.5s" result)))))

(deftest test-conversation-history
  (testing "Conversation history management"
    (reset! core/conversation-history [])
    (is (= 0 (count @core/conversation-history)))

    ;; Simulate adding a message
    (swap! core/conversation-history conj {:role "user" :parts [{:text "Hello"}]})
    (is (= 1 (count @core/conversation-history)))
    (is (= "user" (:role (first @core/conversation-history))))))

(deftest test-stats-tracking
  (testing "Statistics tracking"
    (reset! core/stats {:total-tokens 0 :total-cost 0.0 :request-count 0})

    ;; Simulate updating stats
    (swap! core/stats update :total-tokens + 100)
    (swap! core/stats update :request-count inc)

    (is (= 100 (:total-tokens @core/stats)))
    (is (= 1 (:request-count @core/stats)))))
