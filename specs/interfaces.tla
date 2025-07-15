---------------------------- MODULE interfaces ----------------------------
(* API interface contracts for Gemini REPL *)

EXTENDS Naturals, Sequences, TLC

CONSTANTS
    MaxTokens,       \* Maximum tokens per request
    MaxHistory       \* Maximum conversation history length

VARIABLES
    request,         \* Current API request
    response,        \* API response
    tokens,          \* Token count
    cost             \* Accumulated cost

Init ==
    /\ request = [prompt |-> "", history |-> <<>>]
    /\ response = [content |-> "", tokens |-> 0, success |-> FALSE]
    /\ tokens = 0
    /\ cost = 0

TypeInvariant ==
    /\ request.prompt \in STRING
    /\ request.history \in Seq([role: STRING, text: STRING])
    /\ response.content \in STRING
    /\ response.tokens \in Nat
    /\ response.success \in BOOLEAN
    /\ tokens \in Nat
    /\ cost \in Nat

CreateRequest(prompt, hist) ==
    /\ request' = [prompt |-> prompt, history |-> hist]
    /\ Len(hist) <= MaxHistory
    /\ UNCHANGED <<response, tokens, cost>>

ProcessResponse(content, tokenCount) ==
    /\ response' = [content |-> content, tokens |-> tokenCount, success |-> TRUE]
    /\ tokens' = tokens + tokenCount
    /\ cost' = cost + (tokenCount * 1)  \* Simplified cost calculation
    /\ tokenCount <= MaxTokens
    /\ UNCHANGED request

HandleError ==
    /\ response' = [content |-> "Error", tokens |-> 0, success |-> FALSE]
    /\ UNCHANGED <<request, tokens, cost>>

Next ==
    \/ \E p \in STRING, h \in Seq([role: STRING, text: STRING]) : CreateRequest(p, h)
    \/ \E c \in STRING, t \in 1..MaxTokens : ProcessResponse(c, t)
    \/ HandleError

Spec == Init /\ [][Next]_<<request, response, tokens, cost>>

\* Properties
TokensNeverDecrease == tokens' >= tokens
CostNeverDecreases == cost' >= cost
ValidTokenCount == response.tokens <= MaxTokens

==========================================================================
