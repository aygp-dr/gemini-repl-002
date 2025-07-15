# Conversation Context Documentation

## Overview

The Gemini REPL maintains full conversation history to enable multi-turn dialogues. This allows the AI to understand context from previous messages and handle pronouns like "it", "that", and "this".

## Problem Solved

Without conversation history:
- Each prompt sent in isolation
- Follow-up questions fail
- Pronouns don't resolve
- No contextual understanding

With conversation history:
- Full context sent with each request
- Natural multi-turn conversations
- Pronouns and references work
- Coherent dialogue flow

## Implementation

### State Management

```clojure
(def conversation-history (atom []))
```

The conversation history is stored as a vector of message maps:
```clojure
{:role "user|model"
 :parts [{:text "message content"}]}
```

### Message Flow

1. **User Input**: Added to history before API call
2. **API Request**: Includes full conversation history
3. **Model Response**: Added to history after receiving
4. **Context Maintenance**: All messages preserved

### API Request Format

```clojure
{:contents [{:role "user" :parts [{:text "Hello"}]}
            {:role "model" :parts [{:text "Hi there!"}]}
            {:role "user" :parts [{:text "What's your name?"}]}]}
```

## Commands

### /context Command

Displays the current conversation history:
```
gemini> /context

Conversation History:
1. [user] Hello, can you help me with ClojureScript?
2. [model] Of course! I'd be happy to help you with Clojur...
3. [user] How do I create an atom?
4. [model] In ClojureScript, you create an atom using the...
```

### /clear Command

Resets the conversation history:
```clojure
(reset! conversation-history [])
```

## Memory Management

### Current Approach
- All messages kept in memory
- No automatic pruning
- Manual clear with /clear

### Future Enhancements
1. **Sliding Window**: Keep last N messages
2. **Token Limit**: Prune based on token count
3. **Smart Pruning**: Keep important context
4. **Persistence**: Save/load conversations

## Benefits

1. **Natural Conversations**: Like chatting with a human
2. **Context Awareness**: AI understands references
3. **Follow-up Questions**: Can drill into topics
4. **Debugging**: /context shows full history

## Example Session

```
gemini> Tell me about functional programming

Functional programming is a paradigm that treats computation...

gemini> What are its main principles?

The main principles of functional programming include:
1. Immutability - data doesn't change...
2. Pure functions - no side effects...

gemini> Can you give an example of the second one?

Sure! A pure function example would be...
```

Note how "its" and "the second one" are understood through context.

## Technical Considerations

### Token Limits
- Each message adds tokens
- Gemini has context window limits
- May need pruning for long conversations

### Performance
- Larger context = slower responses
- More tokens = higher cost
- Balance needed

### Privacy
- Full history sent with each request
- Clear sensitive conversations with /clear
- No persistence by default

## Future: Memetic Evolution

The conversation history enables:
1. **Pattern Learning**: Identify common queries
2. **Self-Optimization**: Adapt responses based on usage
3. **Knowledge Accumulation**: Build on previous interactions
4. **Emergent Behaviors**: Discover user preferences

This forms the foundation for the REPL's self-modification capabilities!
