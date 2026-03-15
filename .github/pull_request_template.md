# Pull Request Template

## Description
<!-- Provide a detailed description of your changes -->
<!-- What problem does this PR solve? What feature does it add? -->

Fixes # (issue number)

## Type of Change
<!-- Put an `x` in the boxes that apply -->

- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📝 Documentation update
- [ ] 🎨 Style/formatting changes
- [ ] ♻️ Code refactoring
- [ ] ⚡ Performance improvement
- [ ] 🧪 Test addition/update
- [ ] 🔒 Security fix
- [ ] 🚀 Deployment/CI/CD update

## Changes Made
<!-- List the major changes in this PR -->

1. 
2. 
3. 

## Testing
<!-- Describe the tests you ran to verify your changes -->

### Test Coverage
<!-- Put an `x` in the boxes that apply -->

- [ ] 🧪 Unit tests added/updated
- [ ] 🧪 Widget tests added/updated
- [ ] 🧪 Integration tests added/updated
- [ ] 🧪 Manual testing performed

### Test Instructions
<!-- Provide steps for reviewers to test your changes -->

1. 
2. 
3. 

## Screenshots/Recordings
<!-- If applicable, add screenshots or recordings to help explain your changes -->

| Before | After |
|--------|-------|
|        |       |

## Checklist
<!-- Put an `x` in the boxes that apply. You can also fill these out after creating the PR. -->

### Code Quality
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have updated the CHANGELOG.md (if applicable)

### Security
- [ ] My changes do not introduce security vulnerabilities
- [ ] I have validated all user inputs
- [ ] I have checked for hardcoded secrets/credentials
- [ ] I have verified URL validation is in place (if applicable)
- [ ] I have reviewed error handling and logging

### Performance
- [ ] My changes do not introduce performance regressions
- [ ] I have tested with large datasets (if applicable)
- [ ] I have checked for memory leaks (if applicable)
- [ ] I have verified proper disposal of resources (if applicable)

### Testing
- [ ] All existing tests pass
- [ ] New tests pass
- [ ] Code coverage has not decreased
- [ ] I have added tests that prove my fix/feature works

## Code Review
<!-- Tag reviewers and provide context -->

### Reviewers
<!-- @mention reviewers here -->

- [ ] @reviewer-1
- [ ] @reviewer-2

### Areas of Focus
<!-- Highlight specific areas that need careful review -->

- [ ] Architecture/Design patterns
- [ ] Security implications
- [ ] Performance impact
- [ ] Test coverage
- [ ] Documentation completeness

## Breaking Changes
<!-- If this is a breaking change, describe the impact and migration path -->

**Breaking Change:** Yes / No

**Migration Guide:**
```dart
// Old code:
oldMethod();

// New code:
newMethod();
```

## Related PRs
<!-- Link any related PRs that should be merged together or are dependencies -->

- Related to # (issue/PR number)
- Depends on # (issue/PR number)
- Blocks # (issue/PR number)

## Deployment Notes
<!-- Any special deployment considerations? -->

- [ ] Requires database migration
- [ ] Requires environment variable changes
- [ ] Requires backend API changes
- [ ] Requires configuration updates
- [ ] Can be deployed independently

### Environment Variables
<!-- List any new or changed environment variables -->

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
|          |             |          |         |

## Performance Metrics
<!-- If applicable, provide before/after performance metrics -->

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Build time | | | |
| App size | | | |
| Memory usage | | | |
| Frame rate | | | |

## Additional Context
<!-- Add any other context about the PR here -->

---

## Security Checklist
<!-- Critical for security-related changes -->

- [ ] No hardcoded API keys or secrets
- [ ] Input validation implemented
- [ ] Output encoding in place (if rendering user data)
- [ ] Authentication/authorization checks added (if applicable)
- [ ] Sensitive data encrypted at rest and in transit
- [ ] Error messages don't leak sensitive information
- [ ] Rate limiting considered (if applicable)
- [ ] Dependencies updated and secure

---

## PR Size Guidelines
<!-- Try to keep PRs small and focused -->

- Lines changed: < 400 (ideal), < 800 (acceptable), > 800 (consider splitting)
- Files changed: < 15 (ideal), < 25 (acceptable), > 25 (consider splitting)
- Review time: < 30 minutes (ideal), < 60 minutes (acceptable)

If your PR exceeds these guidelines, consider:
1. Splitting into multiple smaller PRs
2. Creating a follow-up PR for additional features
3. Discussing with the team about the necessity

---

## Merge Strategy
<!-- Indicate preferred merge strategy -->

- [ ] **Squash and Merge** (preferred for feature branches)
- [ ] **Rebase and Merge** (preferred for single-commit changes)
- [ ] **Create a Merge Commit** (preferred for multi-developer features)

---

## Post-Merge Tasks
<!-- Checklist for after the PR is merged -->

- [ ] Verify deployment success
- [ ] Monitor error logs
- [ ] Update documentation if needed
- [ ] Notify stakeholders
- [ ] Close related issues

---

**Thank you for contributing to Erode Super App!** 🎉

*Powered by NJ TECH · Erode*
