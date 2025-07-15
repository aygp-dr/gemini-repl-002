(ns gemini-repl.conversation-test
  (:require [cljs.test :refer-macros [deftest is testing]]
            [gemini-repl.core :as core]))

(deftest test-conversation-history
  (testing "Conversation history management"
    ;; Reset history
    (reset! core/conversation-history [])

    ;; Add user message
    (swap! core/conversation-history conj
           {:role "user" :parts [{:text "Hello"}]})

    (is (= 1 (count @core/conversation-history)))
    (is (= "user" (:role (first @core/conversation-history))))

    ;; Add model response
    (swap! core/conversation-history conj
           {:role "model" :parts [{:text "Hi there!"}]})

    (is (= 2 (count @core/conversation-history)))
    (is (= "model" (:role (second @core/conversation-history))))))

(deftest test-conversation-clear
  (testing "Clear conversation history"
    ;; Add some messages
    (reset! core/conversation-history
            [{:role "user" :parts [{:text "Message 1"}]}
             {:role "model" :parts [{:text "Response 1"}]}])

    (is (= 2 (count @core/conversation-history)))

    ;; Clear history
    (reset! core/conversation-history [])

    (is (= 0 (count @core/conversation-history)))))

(deftest test-message-format
  (testing "Message format validation"
    (let [user-msg {:role "user" :parts [{:text "Test message"}]}
          model-msg {:role "model" :parts [{:text "Test response"}]}]

      (is (= "user" (:role user-msg)))
      (is (= "Test message" (-> user-msg :parts first :text)))

      (is (= "model" (:role model-msg)))
      (is (= "Test response" (-> model-msg :parts first :text))))))

(deftest test-conversation-ordering
  (testing "Messages maintain order"
    (reset! core/conversation-history [])

    ;; Add messages in order
    (doseq [i (range 5)]
      (swap! core/conversation-history conj
             {:role (if (even? i) "user" "model")
              :parts [{:text (str "Message " i)}]}))

    ;; Verify order preserved
    (doseq [i (range 5)]
      (let [msg (nth @core/conversation-history i)]
        (is (= (str "Message " i) (-> msg :parts first :text)))))))
