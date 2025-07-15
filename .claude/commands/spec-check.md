# Specification Check Command

Verifies implementation against formal specifications.

## TLA+ Verification

```bash
cd specs
java -jar ../tools/formal-methods/tla2tools.jar commands.tla
```

## Alloy Verification

```bash
cd specs
java -jar ../tools/formal-methods/alloy.jar state.alloy
```

## Checklist

### Before Implementation
- [ ] Spec exists for feature
- [ ] Spec has been model-checked
- [ ] Edge cases identified

### After Implementation
- [ ] Code matches spec behavior
- [ ] All invariants maintained
- [ ] Properties verified

## Common Properties

1. **Safety**: Nothing bad happens
   - No invalid states
   - Invariants preserved

2. **Liveness**: Good things happen
   - Progress guaranteed
   - Responses generated

3. **Fairness**: All paths possible
   - No starvation
   - Equal opportunity
