# Migration

## Mapping and Description of Variables

### migrated_mod_age

Codes the minimum age the migration module questions of the survey apply to (e.g., if the migration questions are for all 5 years and above this would be 5).

### migrated_ref_time

Codes the reference period the migration questions cover. If the migration questions only apply after an introductory time window questions (e.g., have you moved in the past five years) and then questions are only asked for those who fall within the time window, code the length of that window (e.g., 5 in the example). If migration questions are posed regardless of time (i.e., no time window) code 99.

### migrated_binary

Binary question coding whether the individual has ever migrated (within the reference time set out above).

### migrated_years

Number of full years since the last migration. Often surveys ask how long a person has lived at their current domicile since the last migration. Both questions cover the same information.

### migrated_from_urban

Codes whether the individual migrated to their current domicile from an urban area.

1 = Yes (i.e., came from urban area)

0 = No (i.e., came from rural area)

### migrated_from_cat

If the survey contains information on the area from where the person migrated, use the [concept of administrative division](https://en.wikipedia.org/wiki/Administrative_division) to inform the migration pattern. The codes are:

1 = From same admin3 area

2 = From same admin2 area

3 = From same admin1 area

4 = From other admin1 area

5 = From other country

To exemplify the use, Spain is divided into Communities (admin1 level), Provinces (admin2 level) and municipalities (names change within provinces, but rough concept holds – admin3 level). A person moving within the municipality, for example, from one village to the next, codes 1. A person moving within the province, say from a rural municipality to the province capital codes 2. A person moving within the same community yet leaving their province codes 3. A person moving from one community to another, say from [Andalusia](https://en.wikipedia.org/wiki/Andalusia) to [Galicia](https://en.wikipedia.org/wiki/Galicia_%28Spain%29), codes 4. If the person moved from outside the country (regardless of their nationality) codes 5.

### migrated_from_code

Based on the logic set out in the _migrated_from_cat_ variable, codify the areas of migration using the survey subnation id classification. For example, if a person migrated from one admin1 area to another, use the subnatid1 codes to inform from which admin1 area they migrated to their current residence (which is codified in subnatid1).

This only codifies information within the country. Set to missing if migrated_from_cat is 5.

Note that most surveys will only provide information of last residence to a higher administrative level (e.g., admin1 level). Codify the information up to the highest level possible. See an example in 5.2 below.

### migrated_from_country

Codes the country (if migrated_from_cat is 5) from where the person migrated from as a [three letter ISO country code](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3) or a clear string for regions (“Other Europe”, “Other World”, …)

### migrated_reason

Codifies the reason why a person migrated. The codes are:

1 = Family reasons

2 = Educational reasons

3 = Employment

4 = Forced (political reasons, natural disaster, …)

5 = Other reasons

## Lessons Learned and Challenges

### Codifying _migrated_from_\* questions_

In the Indian LFS from 1999 (NSS Schedule 10) there are two questions that allow us to codify the four migrated_from_\[text\] variables (migrated_from_urban, migrated_from_cat, migrage_from_code, and migrated_from_country).

Question 15 of Block 4 asks interviewer to enter the “location code” for the kind of migration the interviewees claim to have made. The codes are:

_location of last usual residence: same district: rural-1, urban-2; same state but another district: rural-3, urban-4; another state: rural-5, urban-6; another country-7_

Question 17 of Block 4 then asks for the state code of migration (as codified in subnatid) and adds additional codes for countries from where people commonly migrated into India.

With these two questions we can harmonize the two variables in the following way:

```
*<_migrated_from_urban_>
    gen migrated_from_urban = .
    replace migrated_from_urban = 1 if inlist(B4_q15,"2","4","6") & migrated_binary == 1
    replace migrated_from_urban = 0 if inlist(B4_q15,"1","3","5") & migrated_binary == 1
    label de lblmigrated_from_urban 0 "Rural" 1 "Urban"
    label values migrated_from_urban lblmigrated_from_urban
    label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>
	
*<_migrated_from_cat_>
    gen migrated_from_cat = .
    replace migrated_from_cat = 2 if inlist(B4_q15,"1","2") & migrated_binary == 1
    replace migrated_from_cat = 3 if inlist(B4_q15,"3","4") & migrated_binary == 1
    replace migrated_from_cat = 4 if inlist(B4_q15, "5", "6") & migrated_binary == 1
    replace migrated_from_cat = 5 if inlist(B4_q15, "7") & migrated_binary == 1
    label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country"
    label values migrated_from_cat lblmigrated_from_cat
    label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>
	
*<_migrated_from_code_>
    destring B4_q17, gen(helper_var)
    gen migrated_from_code = .
    replace migrated_from_code = subnatid1 if inrange(migrated_from_cat,1,3)
    replace migrated_from_code = helper_var if migrated_from_cat == 4
    label var migrated_from_code "Code of migration area as subnatid
    level of migrated_from_cat"
    drop helper_var
*</_migrated_from_code_>
	
*<_migrated_from_country_>
    gen migrated_from_country = ""
    replace migrated_from_country = "BGD" if migrated_from_cat == 5 & B4_q17 == "51"
    replace migrated_from_country = "NPL" if migrated_from_cat == 5 & B4_q17 == "52"
    replace migrated_from_country = "PAK" if migrated_from_cat == 5 & B4_q17 == "53"
    replace migrated_from_country = "LKA" if migrated_from_cat == 5 & B4_q17 == "54"
    replace migrated_from_country = "BTN" if migrated_from_cat == 5 & B4_q17 == "55"
    replace migrated_from_country = "Gulf countries" if migrated_from_cat == 5 & B4_q17 == "56"
    replace migrated_from_country = "Other Asian" if migrated_from_cat == 5 & B4_q17 == "57"
    replace migrated_from_country = "USA" if migrated_from_cat == 5 & B4_q17 == "58"
    replace migrated_from_country = "CAN" if migrated_from_cat == 5 & B4_q17 == "59"
    replace migrated_from_country = "Other Americas" if migrated_from_cat == 5 & B4_q17 == "60"
    replace migrated_from_country = "UK" if migrated_from_cat == 5 & B4_q17 == "61"
    replace migrated_from_country = "Other Europe" if migrated_from_cat == 5 & B4_q17 == "62"
    replace migrated_from_country = "African countries" if migrated_from_cat == 5 & B4_q17 == "63"
    replace migrated_from_country = "Other World" if migrated_from_cat == 5 & B4_q17 == "64"
    label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>
```

## Tabular Overview of Variables

| Module Code | Variable name | Variable label | Notes |
| --- | --- | --- | --- |
| Migration | migrated_mod_age | Migration module application age | &nbsp; |
| Migration | migrated_ref_time | Reference time applied to migration questions | If migrated_ref_time = 5 means questions about migration refer to any migration in the last 5 years |
| Migration | migrated_binary | Individual has migrated | &nbsp; |
| Migration | migrated_years | Years since latest migration | Years since last migration is the same as how long lived at current location |
| Migration | migrated_from_urban | Migrated from area | No means migrated from rural area |
| Migration | migrated_from_cat | Category of migration area |     |
| Migration | migrated_from_code | Code of migration area |     |
| Migration | migrated_from_country | Code of migration country |     |
| Migration | migrated_reason | Reason for migrating |     |

