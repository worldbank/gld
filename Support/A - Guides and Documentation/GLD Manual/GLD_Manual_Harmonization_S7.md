# Training

## Mapping and Description of Variables

### vocational

Codifies whether the person ever attended vocational training. The codes are:

0 = No

1 = Yes

### vocational_type

Codifies whether the vocational training took place within the enterprise or was administered by an external party. The codes are:

1 = Inside Enterprise

2 = External

### vocational_length_l

Codifies how long the training was in months. Divided into lower and upper in case the information is coded as a range (e.g., 0-3 months, 6-12 months, …). If it is an exact number, lower and upper length are equal.

### vocational_length_u

see _vocational_length_u_

### vocational_field_orig

Information on the field of training as stored originally in the survey. This variable is to be a string variable. If numeric convert to string while preserving its original structure.

### vocational_financed

Text. The codes are:

1 = Employer

2 = Government

3 = Mixed Employer-Government

4 = Own funds

5 = Other

## Lessons Learned and Challenges

Text

## Tabular Overview of Variables

| Module Code | Variable name | Variable label | Notes |
| --- | --- | --- | --- |
| Education | vocational | Ever received vocational training | &nbsp; |
| Education | vocational_type | Type of vocational training | &nbsp; |
| Education | vocational_length_l | Length of training, lower limit | &nbsp; |
| Education | vocational_length_u | Length of training, upper limit | &nbsp; |
| Education | vocational_field_orig | Original field of training information |     |
| Education | vocational_financed | How training was financed | If funded with different sources, chose main source |