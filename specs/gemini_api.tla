---------------------------- MODULE gemini_api ----------------------------
(* Gemini API interaction specification *)

EXTENDS Naturals, Sequences, TLC

CONSTANTS
    Models,          \* Set of available models
    MaxRetries       \* Maximum retry attempts

VARIABLES
    model,           \* Current model
    endpoint,        \* API endpoint state
    retries,         \* Retry counter
    lastError        \* Last error message

Init ==
    /\ model \in Models
    /\ endpoint = "available"
    /\ retries = 0
    /\ lastError = ""

TypeInvariant ==
    /\ model \in Models
    /\ endpoint \in {"available", "busy", "error", "maintenance"}
    /\ retries \in 0..MaxRetries
    /\ lastError \in STRING

CallAPI ==
    /\ endpoint = "available"
    /\ endpoint' = "busy"
    /\ UNCHANGED <<model, retries, lastError>>

SuccessResponse ==
    /\ endpoint = "busy"
    /\ endpoint' = "available"
    /\ retries' = 0
    /\ lastError' = ""
    /\ UNCHANGED model

ErrorResponse(error) ==
    /\ endpoint = "busy"
    /\ endpoint' = "error"
    /\ lastError' = error
    /\ retries' = retries + 1
    /\ UNCHANGED model

RetryRequest ==
    /\ endpoint = "error"
    /\ retries < MaxRetries
    /\ endpoint' = "available"
    /\ UNCHANGED <<model, retries, lastError>>

GiveUp ==
    /\ endpoint = "error"
    /\ retries >= MaxRetries
    /\ endpoint' = "available"
    /\ retries' = 0
    /\ UNCHANGED <<model, lastError>>

SwitchModel(newModel) ==
    /\ endpoint = "available"
    /\ newModel \in Models
    /\ model' = newModel
    /\ UNCHANGED <<endpoint, retries, lastError>>

Next ==
    \/ CallAPI
    \/ SuccessResponse
    \/ \E err \in STRING : ErrorResponse(err)
    \/ RetryRequest
    \/ GiveUp
    \/ \E m \in Models : SwitchModel(m)

Spec == Init /\ [][Next]_<<model, endpoint, retries, lastError>>

\* Properties
EventuallyAvailable == <>(endpoint = "available")
RetryBounded == retries <= MaxRetries

==========================================================================
