---------------------------- MODULE commands ----------------------------
(* Formal specification of Gemini REPL command processing *)

EXTENDS Sequences, TLC

CONSTANTS Commands    \* Set of valid commands
VARIABLES
    input,           \* Current input string
    state,           \* Current REPL state
    history,         \* Conversation history
    output           \* Output to display

Init ==
    /\ input = ""
    /\ state = "ready"
    /\ history = <<>>
    /\ output = ""

TypeInvariant ==
    /\ input \in STRING
    /\ state \in {"ready", "processing", "error"}
    /\ history \in Seq(STRING)
    /\ output \in STRING

ProcessCommand(cmd) ==
    /\ state = "ready"
    /\ input = cmd
    /\ state' = "processing"
    /\ CASE cmd = "/help" -> output' = "Available commands..."
         [] cmd = "/exit" -> state' = "exit"
         [] cmd = "/clear" -> history' = <<>>
         [] cmd = "/stats" -> output' = "Statistics..."
         [] cmd = "/context" -> output' = "Context..."
         [] cmd = "/debug" -> output' = "Debug toggled"
         [] OTHER -> output' = "Unknown command"
    /\ UNCHANGED <<input, history>>

ProcessMessage(msg) ==
    /\ state = "ready"
    /\ input = msg
    /\ ~(msg \in Commands)
    /\ state' = "processing"
    /\ history' = Append(history, msg)
    /\ output' = "API response"
    /\ UNCHANGED input

CompleteProcessing ==
    /\ state = "processing"
    /\ state' = "ready"
    /\ input' = ""
    /\ UNCHANGED <<history, output>>

Next ==
    \/ \E cmd \in Commands : ProcessCommand(cmd)
    \/ \E msg \in STRING : ProcessMessage(msg)
    \/ CompleteProcessing

Spec == Init /\ [][Next]_<<input, state, history, output>>

\* Safety properties
NoInvalidStates == state \in {"ready", "processing", "error", "exit"}
HistoryNeverShrinks == \A i \in 1..Len(history) : history[i] \in STRING

==========================================================================
