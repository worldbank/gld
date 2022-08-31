#Best Practices for self review in open source contributions

### Self review

You should always review your own PR first.

For content changes, make sure that you:

- [ ] Confirm that the changes meet the user experience and goals outlined in the content design plan (if there is one).
- [ ] Compare your pull request's source changes to staging to confirm that the output matches the source and that everything is rendering as expected. This helps spot issues like typos, content that doesn't follow the style guide, or content that isn't rendering due to versioning problems. Remember that lists and tables can be tricky.
- [ ] Review the content for technical accuracy.
- [ ] Copy-edit the changes for grammar, spelling, and adherence to the [style guide](https://github.com/github/docs/blob/main/contributing/content-style-guide.md).
- [ ] Check new or updated Liquid statements to confirm that versioning is correct.
- [ ] If there are any failing checks in your PR, troubleshoot them until they're all passing.
- [ ] For non-native language users, kindly use the english language to propose changes.
- [ ] Make sure that you are proposing a change in the correct branch, since this repository has restrictions. Check that the if changes you propose are located in a PR separate to the main branch.


#Attribution

The content in this post relates to the [github guidelines for self-review](https://github.com/github/docs/blob/5435cce9e2bcb102ed73877e442190a50567a2d9/contributing/self-review.md).
