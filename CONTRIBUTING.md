
# Welcome to the GLD repository contributing guide <!-- omit in toc -->

Thank you for investing your time in contributing to the GLD project! Any contribution you make will be reflected on [worldbank/gld](https://github.com/worldbank/gld) :sparkles: 

Read our [Code of Conduct](https://github.com/worldbank/gld/blob/ccfabd4a45e8804d4b8886711366f765cf1e2c37/Support/E%20-%20Community%20Guidelines/CODE_OF_CONDUCT.md) to keep our community approachable and respectful.

In this guide you will get an overview of the contribution workflow from opening an issue, creating a pull request (PR), reviewing, and merging the PR.

## Getting started

To get an overview of the project, read the [README](README.md). 

Check to see what [types of contributions](https://github.com/worldbank/gld/blob/b08f35fbe3b519bafcc1d02c8fee6e82ca503f87/Support/E%20-%20Community%20Guidelines/type_of_contributions.md) we accept before making changes. Some of them don't even require writing a single line of code :sparkles:.

### Issues

#### Create a new issue

If you spot a problem with the docs, [search if an issue already exists](https://docs.github.com/en/github/searching-for-information-on-github/searching-on-github/searching-issues-and-pull-requests#search-by-the-title-body-or-comments). If a related issue doesn't exist, you can open a new issue using a relevant [issue form](https://github.com/github/docs/issues/new/choose). 

#### Solve an issue

Scan through our [existing issues](https://github.com/github/docs/issues) to find one that interests you. You can narrow down the search using `labels` as filters. See [Labels](/contributing/how-to-use-labels.md) for more information. As a general rule, we don’t assign issues to anyone. If you find an issue to work on, you are welcome to open a PR with a fix.

### Make Changes

#### Make changes in the UI

Click **Make a contribution** at the bottom of any docs page to make small changes such as a typo, sentence fix, or a broken link. This takes you to the `.md` file where you can make your changes and [create a pull request](#pull-request) for a review. 

 <img src="./assets/images/contribution_cta.png" width="300" height="150" /> 

#### Make changes in a codespace

For more information about using a codespace for working on GitHub documentation, see "[Working in a codespace](https://github.com/github/docs/blob/main/contributing/codespace.md)."

#### Make changes locally

1. [Install Git LFS](https://docs.github.com/en/github/managing-large-files/versioning-large-files/installing-git-large-file-storage).

2. Fork the repository.
- Using GitHub Desktop:
  - [Getting started with GitHub Desktop](https://docs.github.com/en/desktop/installing-and-configuring-github-desktop/getting-started-with-github-desktop) will guide you through setting up Desktop.
  - Once Desktop is set up, you can use it to [fork the repo](https://docs.github.com/en/desktop/contributing-and-collaborating-using-github-desktop/cloning-and-forking-repositories-from-github-desktop)!

- Using the command line:
  - [Fork the repo](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo#fork-an-example-repository) so that you can make your changes without affecting the original project until you're ready to merge them.

3. Install or update to **Node.js v16**. For more information, see [the development guide](contributing/development.md).

4. Create a working branch and start with your changes!

### Commit your update

Commit the changes once you are happy with them. See [Atom's contributing guide](https://github.com/atom/atom/blob/master/CONTRIBUTING.md#git-commit-messages) to know how to use emoji for commit messages.

Once your changes are ready, don't forget to [self-review](/contributing/self-review.md) to speed up the review process:zap:.

### Pull Request

When you're finished with the changes, create a pull request, also known as a PR.
- Fill the "Ready for review" template so that we can review your PR. This template helps reviewers understand your changes as well as the purpose of your pull request. 
- Don't forget to [link PR to issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue) if you are solving one.
- Enable the checkbox to [allow maintainer edits](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/allowing-changes-to-a-pull-request-branch-created-from-a-fork) so the branch can be updated for a merge.
Once you submit your PR, a Docs team member will review your proposal. We may ask questions or request for additional information.
- We may ask for changes to be made before a PR can be merged, either using [suggested changes](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/incorporating-feedback-in-your-pull-request) or pull request comments. You can apply suggested changes directly through the UI. You can make any other changes in your fork, then commit them to your branch.
- As you update your PR and apply changes, mark each conversation as [resolved](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/commenting-on-a-pull-request#resolving-conversations).
- If you run into any merge issues, checkout this [git tutorial](https://github.com/skills/resolve-merge-conflicts) to help you resolve merge conflicts and other issues.

### Your PR is merged!

Congratulations :tada::tada: The GLD team thanks you :sparkles:. 

## How can you help with this repository?

If you wish to help improve this repository, you are more than welcome to – and we’d greatly appreciate it. There are three major ways to help us out.

### Report your experience

The simplest way is to just tell us about your experience. Did you find everything you needed? Were you able to run all the files? Was the process comprehensible to you? Feedback on your experience interacting with the repository helps us improve it, so please feel free to get in touch with the [GLD Focal Point](mailto:gld@worldbank.org).

### Report errors you spotted

In addition to reporting on your experience, as you run and use the harmonization you may spot errors in the code. We harmonize conscientiously and run our harmonization through a set of checks, yet some errors we cannot spot. If you spot any of those please either write to the [GLD Focal Point](mailto:gld@worldbank.org) or, even better, raise an issue we can all see, if possible with a link to [particular section of the code in question](https://docs.github.com/en/github/writing-on-github/working-with-advanced-formatting/creating-a-permanent-link-to-a-code-snippet).

### Harmonize a new survey yourself 

Finally, if you are working on a project that needs a harmonization, please feel free to do it to our standard, we’d be excited to host your contribution. You may find the [data dictionary](https://github.com/worldbank/gld/blob/main/Support/Guides%20and%20Documentation/GLD_Dictionary_v01.xlsx) on our site as well as [the GLD harmonization template](/Support/Templates/GLD_Harmonization_Template.do). You may fork our repository, run through [the quality checks](/Support/Q%20Checks) and create a pull request and we will review it to add it to the collection.

