# Experiment Command

Sets up experimental branches for testing new ideas.

## Process

1. **Create experiment directory**
   ```bash
   mkdir -p experiments/EXP-XXX-description
   ```

2. **Document goals**
   - What are we testing?
   - What's the hypothesis?
   - Success metrics?

3. **Implement prototype**
   - Keep code isolated
   - Use minimal dependencies
   - Focus on core concept

4. **Document results**
   - What worked?
   - What didn't?
   - Should it be integrated?

## Example Structure

```
experiments/
└── EXP-001-streaming-responses/
    ├── README.md
    ├── prototype.cljs
    └── results.md
```
