---------------------------- MODULE api_client ----------------------------
(* Client behavior specification for Gemini REPL *)

EXTENDS Naturals, Sequences, FiniteSets

CONSTANTS
    Users,           \* Set of users
    RateLimit        \* Max requests per user per time window

VARIABLES
    userRequests,    \* Map of user -> request count
    activeRequests,  \* Set of active requests
    responses,       \* Queue of responses
    rateLimited      \* Set of rate-limited users

Init ==
    /\ userRequests = [u \in Users |-> 0]
    /\ activeRequests = {}
    /\ responses = <<>>
    /\ rateLimited = {}

TypeInvariant ==
    /\ userRequests \in [Users -> Nat]
    /\ activeRequests \subseteq Users
    /\ responses \in Seq(Users)
    /\ rateLimited \subseteq Users

SendRequest(user) ==
    /\ user \in Users
    /\ user \notin rateLimited
    /\ user \notin activeRequests
    /\ userRequests[user] < RateLimit
    /\ activeRequests' = activeRequests \cup {user}
    /\ userRequests' = [userRequests EXCEPT ![user] = @ + 1]
    /\ UNCHANGED <<responses, rateLimited>>

ReceiveResponse(user) ==
    /\ user \in activeRequests
    /\ activeRequests' = activeRequests \ {user}
    /\ responses' = Append(responses, user)
    /\ UNCHANGED <<userRequests, rateLimited>>

ApplyRateLimit(user) ==
    /\ user \in Users
    /\ userRequests[user] >= RateLimit
    /\ rateLimited' = rateLimited \cup {user}
    /\ UNCHANGED <<userRequests, activeRequests, responses>>

ResetWindow ==
    /\ userRequests' = [u \in Users |-> 0]
    /\ rateLimited' = {}
    /\ UNCHANGED <<activeRequests, responses>>

Next ==
    \/ \E u \in Users : SendRequest(u)
    \/ \E u \in Users : ReceiveResponse(u)
    \/ \E u \in Users : ApplyRateLimit(u)
    \/ ResetWindow

Spec == Init /\ [][Next]_<<userRequests, activeRequests, responses, rateLimited>>

\* Properties
NoDoubleRequests == \A u \in Users : u \in activeRequests => userRequests[u] > 0
RateLimitRespected == \A u \in Users : userRequests[u] <= RateLimit

==========================================================================
