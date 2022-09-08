# Welcome to the GLD repository contributing guide <!-- omit in toc -->

Thank you for investing your time in contributing to the GLD project! Your contribution will improve the [GLD project](https://github.com/worldbank/gld) .:sparkles: 

Read our [Code of Conduct](/Support/E%20-%20Community%20Guidelines/CODE_OF_CONDUCT.md) to keep our community approachable and respectful.

In this guide you will get an overview of the contribution workflow from opening an issue, creating a pull request (PR), reviewing, to merging the PR.

## Getting started

To get an overview of the project, read the [README](README.md). 

Check to see what [types of contributions](/Support/E%20-%20Community%20Guidelines/type_of_contributions.md) we accept before making changes. Some of them don't even require writing a single line of code :sparkles:.

### Issues

#### Create a new issue

If you spot a problem in any of the harmonization codes or documents, [search if an issue already exists](https://github.com/worldbank/gld/issues). If a related issue does not exist, you can open a new issue using a relevant [issue form](). 

#### Solve an issue

Scan through our [existing issues](https://github.com/worldbank/gld/issues) to find one that interests you. You can narrow down the search using `labels` as filters. See [Labels](/Support/E%20-%20Community%20Guidelines/gld_labels.md) for more information. As a general rule, we don’t assign issues to anyone. If you find an issue to work on, you are welcome to open a PR with a fix or to send as an email if the issue is restricted.

### Make Changes

#### Make changes

Click **Edit** at  right upper side of the page of any document or code to make small changes such as a typo, sentence fix, or a broken link. This takes you to the `.md` file where you can make your changes and [create a pull request](#pull-request) for a review. 

#### Make changes locally

Local changes (changes directly on the GLD repository) are only open to World Bank users. Additionally, only members of the World Bank GitHub organization (which you join via eService Request) are eligible to be added to the GLD team. Only the GLD team can make changes locally

However, please feel free to propose your changes in a PR and the focal point will assess the contribution and accept it or reject it accordingly.


### Report your experience

The simplest way is to just tell us about your experience. Did you find everything you needed? Were you able to run all the files? Was the process comprehensible to you? Feedback on your experience interacting with the repository helps us improve it, so please feel free to get in touch with the [GLD Focal Point](mailto:gld@worldbank.org).

### Report errors you spotted

In addition to reporting on your experience, as you run and use the harmonization you may spot errors in the code. We harmonize conscientiously and run our harmonization through a set of checks, yet some errors we cannot spot. If you spot any of those please either write to the [GLD Focal Point](mailto:gld@worldbank.org) or, even better, raise an issue we can all see, if possible with a link to [particular section of the code in question](https://docs.github.com/en/github/writing-on-github/working-with-advanced-formatting/creating-a-permanent-link-to-a-code-snippet).

### Harmonize a new survey yourself 

Finally, if you are working on a project that needs a harmonization, please feel free to do it to our standard, we’d be excited to host your contribution. You may find the [data dictionary](https://github.com/worldbank/gld/blob/main/Support/Guides%20and%20Documentation/GLD_Dictionary_v01.xlsx) on our site as well as [the GLD harmonization template](/Support/Templates/GLD_Harmonization_Template.do). You may fork our repository, run through [the quality checks](/Support/Q%20Checks) and create a pull request and we will review it to add it to the collection.

#### Create a Pull Request

When you're finished with the changes, create a pull request, also known as a PR.
- Fill the "Ready for review" template so that we can review your PR. This template helps reviewers understand your changes as well as the purpose of your pull request. 
- Don't forget to [link PR to issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue) if you are solving one.
- Enable the checkbox to [allow maintainer edits](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/allowing-changes-to-a-pull-request-branch-created-from-a-fork) so the branch can be updated for a merge.
Once you submit your PR, The GLD team will review your proposal. We may ask questions or request for additional information.
- We may ask for changes to be made before a PR can be merged, either using [suggested changes](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/incorporating-feedback-in-your-pull-request) or pull request comments. You can apply suggested changes directly through the UI. You can make any other changes in your fork, then commit them to your branch.
- As you update your PR and apply changes, mark each conversation as [resolved](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/commenting-on-a-pull-request#resolving-conversations).
- If you run into any merge issues, checkout this [git tutorial](https://github.com/skills/resolve-merge-conflicts) to help you resolve merge conflicts and other issues.
- Please use the general guidance for [self-review](https://github.com/worldbank/gld/blob/75b6ddf818eac3482df4e90dd960ba8482dcf814/Support/E%20-%20Community%20Guidelines/self_review.md) to minimize back and forth with the reviewers.


### Your PR is merged!

Congratulations :tada::tada: The GLD team thanks you :sparkles:. 

### General Information on how to draft a PR or email 

Filing the Pull Request
-----------------------

If you don't yet know how to file a pull request, read [GitHub's
document about it](https://help.github.com/articles/using-pull-requests).

Make your pull request be the addition of a single file to the
[issues](issues) directory of this project. Name the file
with the same name as your GitHub userid, with `.md` appended to the
end. For example, for the user `generic-user`, the full path to the file
would be `issues/generic-user.md`.

Put the following in the file:

```
[date]

I hereby agree to the terms of the Contribution guidelines and code of conduct of the community.

I furthermore declare that I am authorized and able to make this
agreement and sign this declaration.

Signed,

[your name]
https://github.com/[your github userid]
```

Replace the bracketed text as follows:

* `[date]` with today's date, in the unambiguous numeric form `YYYY-MM-DD`.
* `[your name]` with your name.
* `[your github userid]` with your GitHub userid.

```

If the output is different from above, let us know.

That's it!

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Send an Email to the team
-----------------

Send an email to the GLD team
at [gld@worldbank.org](mailto:gld@worldbank.org),
with the subject "Acknowledgment of Contribution Rules" and the following body:

```
I submitted a pull request to indicate agreement to code of conduct and contribution guidelines.

Signed,

[Your Name]
https://github.com/[your github userid]
[your address]
[your phone number]
```

Replace the bracketed text as follows:

* `[your name]` with your name.
* `[your github userid]` with your GitHub userid.
* `[your address]` with a physical mailing address at which you can be
  contacted.
* `[your phone number]` with a phone number at which you can be contacted.

```
#### Attribution

The information on this page has been adapted from the [GLD contribution template](https://github.com/auth0/open-source-template/blob/master/GENERAL-CONTRIBUTING.md) .

