# Title 1. General provisions

The rules in this title apply to every variable in every title. A section in
another title refers to a rule here. It does not repeat it.

| Section | Subject |
|---|---|
| § 1.1 | Codes for missing information |

---

## § 1.1 Codes for missing information

**(a) Rule.**

(1) A value that the questionnaire or the codebook of the survey defines as
"don't know", "refused", or "not stated" shall be coded as missing (`.`),
rather than some other value such as "98", "99" or "999".

(2) For a string variable, the missing value is the empty string (`""`).

**(b) Scope.** This rule applies to every variable, unless the section for
that variable states an exception.

**(c) Exceptions.** A number such as 98 or 99 is not a missing code when the
survey or the GLD uses it as a real value. Two examples:

(1) In `age`, 98 can be an age. See § 2.2(e).

(2) In the Labor title, 99 is a harmonized category, "99 = Other/unspecified".

**(d) Notes.**

(1) *Reason for the rule.* The code for missing information changes from
survey to survey. One NSO uses 98, another uses 99 or 999, and a third uses
-1. So the rule names the purpose of the code, and the questionnaire or the
codebook of each survey shows which codes have that purpose. A rule that
names one number would delete real values in the cases of paragraph (c).

(2) *Source.* The original manual stated this rule in four places.
`Demography.md` line 11 (`age`): "if the information on age is not
available, it should be coded as missing rather than some other value such as
"99" or "999"." Lines 15 (`male`) and 45 (`marital`): "Variable values coded
as '98' or other numeric characters should be excluded". Line 22
(`relationharm`): "Variable values coded as '98' or other placeholder codes
should be excluded". This section replaces all four.
