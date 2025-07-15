# Mise en Place Command

"Everything in its place" - Preparation before starting work.

## Checklist

### Environment Setup
- [ ] `.env` file exists with API key
- [ ] Dependencies installed (`npm install`)
- [ ] Shadow-CLJS running (`gmake dev`)
- [ ] Logs directory created

### Verification
- [ ] Run `gmake lint` - no errors
- [ ] Run `gmake test` - all passing
- [ ] Check `git status` - clean working tree

### Formal Methods
- [ ] TLA+ tools available
- [ ] Alloy analyzer ready
- [ ] Specs up to date

### Development Tools
- [ ] REPL connected
- [ ] Editor configured
- [ ] Terminal ready

## Quick Start

```bash
# Full setup
gmake install
cp .env.example .env
# Edit .env with API key
gmake dev
```
