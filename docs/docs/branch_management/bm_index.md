---
layout: default
title: Git Branch Management
nav_order: 6
---

# GLD GitHub Repository Branching Guidelines

## What is this document?

This document sets the guidelines on how to create, name, and manage branches on the GLD repository. It is aimed at both individuals developing new code on the repository and users of the repository who only consume code. Upon reading, users should be able to understand how the branches structure the code and at what stage each project is. Developers should, in addition, implement their code in the outlined manner to ensure consistency across projects and developers.

## What are branches and why do we need them?

A Git is a bifurcation of the state of code that creates a new path for the evolution of it. It can be parallel to other Git branches that you can generate (see [here a tutorial on Git branches]( https://www.hostinger.com/tutorials/how-to-use-git-branches/), from where this explanation is from). Two of the main advantages are:

- It is possible to develop new features for our application without hindering the development in the main branch.
- With Git branches it is possible to create different development branches that can converge in the same repository. For example, a stable branch, a test branch, and an unstable branch.

In the context of GLD, we need a main branch as the place where users can find the code for the validated harmonizations that have been added to the database. In addition, we need a place to store code that we are working on and want to discuss with others, e.g., a new survey we wish to harmonize. The development, however, should not appear on the main branch to not provide users with unfinished code. We need a branch to work on the new survey and incorporate it only once we are finished. 

## When is new information created?

We then develop new content by:

- Creating harmonization code for a country, survey, year;
- Creating support documentation for a country, survey, year;
- Creating general support documentation (templates, q-checks, …).

## The three-tier branching system

### Overview

The three-tier branching system is based on the GitFlow Workflow. The image below explains the general idea (find more information in the source for this image: [Part 2 of this DIME presentation on Git]( https://github.com/worldbank/DIME-Resources/blob/master/git-3-flow.pdf)).

![image]({{site.baseurl}}/assets/images/gitflow_dime_image.png)

### GLD implementation

In the GLD context, the **main** (or master) **branch contains all the code for validated harmonizations** as well as the latest stable version of any support information (e.g., coding templates, quality checks, and data dictionary). It represents the public record of the project.

The **develop branch represents the work done on a standalone code expansion** (e.g., by adding a new survey). It is created at the start of the project and will only be merged once it is completed and validated (e.g., after all quality checks have passed).

Inside each develop branch **a feature branch progresses a substantial piece of project work** (e.g. the creation or revision of unique household identifiers). This reduces the number of commits to the develop branch and allows developers to try approaches without compromising the project’s develop branch.

### When to create a feature branch versus committing to the develop branch directly

The distinction between the main and the develop branch is that the latter is an ongoing project that will be added to the former only at its conclusion. The distinction between the develop branch and the feature branch is not as clear. This is a guideline and not prescriptive. It depends on the developer and the circumstances. The developer may commit advances directly to the develop branch or create a feature branch that will be merged in later in the way that best suits their workflow. However, as rule of thumb, one should:

- Commit small advances (e.g., corrected a typo like “Wolrd Bank” to “World Bank” in one year’s code) directly to the develop branch;
- Create a feature branch for any major piece of work (e.g., trialling a system to convert a national occupation classification system to ISCO);
- Discuss with a colleague how to handle feature branches if there is more than one person working on a particular project and develop branch.

### Naming rules for branches

There are two kinds of projects that merit a develop branch. Either a new survey is being added and the branch will contain the harmonization code relating to it, or general GLD support operations are amended or added (e.g., changes to the quality checks).

In the case of the former, the branch should simply have the [ISO alpha-3 letter code]( https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3) of the country covered (e.g., **THA** for Thailand). Only if a country develop branch already exists should the name include the survey acronym, separated by a dash from the country three letter code (e.g., **THA-lfs** for the Thailand Labour Force Survey).

If the project is not a country survey, the name of the develop branch should be a shorthand description of the process, e.g., **expnd-Qcheck** for a project expanding the quality checks.

Any feature branch of a develop branch should contain the develop branch name and add a shorthand description of the feature, separated from the original name by a dash. For example, for a feature reviewing consistency of household identifiers in Thailand, this would be: **THA-hhid-review** (or **THA-lfs-hhid-review** if there already was a different **THA** develop branch). For the case of adding a feature to the exporting of the information of the quality checks in a new Excel table which may be more informative, the feature branch could be named: **expnd-Qcheck-export-xlsx**.
