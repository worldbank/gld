# Labor force status

This note describes how GLD assigns current labor-force status in the Honduras EPHPM harmonized files for 2021 to 2025. The data files use different raw variable names across years, but the questionnaire concepts are mostly stable. For this reason, the note describes the questionnaire definitions used for harmonization rather than the raw variable names.

## Minimum labor age

The EPHPM labor screening questions start below age 15, but GLD current labor-force status is assigned only for persons age 15 and above. People below age 15 are left outside the GLD current labor-force-status universe.

## Employment

Employment is assigned before unemployment. The questionnaire identifies employment through the following routes. The routes are applied in questionnaire order, so a person already counted through an earlier route is not counted again through a later route.

| Employment route | Questionnaire information | Years covered |
| --- | --- | --- |
| Direct work for pay or profit | Worked at least one hour in the reference week and received, or expected to receive, pay, profit, or in-kind income. | 2021-2025 |
| Other listed economic activity | Did a listed one-hour economic activity for pay or profit that was not captured by the first work question. | 2021-2025 |
| Temporary absence for a protected reason | Had a job, business, or economic activity but was temporarily absent for a questionnaire-recognized reason, such as vacation, holiday, training, maternity leave, illness, or accident. | 2021-2025 |
| Temporary absence with continued income | Was temporarily absent from a job, business, or economic activity but continued to receive pay, profit, or income. | 2021-2025 |
| Short temporary absence | Was temporarily absent and had already returned, expected to return soon, or expected the absence to last three months or less. | 2021-2025 |
| Unpaid family work, without retained market-orientation detail | Helped a family member without pay in an economic activity, business, or farm. The retained information does not identify whether this family work was mainly for sale or mainly for household consumption. | 2021-2022 |
| Unpaid family work mainly for sale | Helped a family member without pay in an economic activity, business, or farm, and the activity was mainly for sale. | 2023-2025 |
| Other unpaid work after no unpaid family work | Did other unpaid work only after not reporting unpaid family work. The retained categories identify volunteer work, unpaid internship or apprenticeship, own-household domestic work, and production for household consumption. | 2021-2022 |

The main comparability issue is unpaid family work. This route is treated differently across rounds because the retained market-orientation detail differs. In 2021 and 2022, the retained data identify the unpaid-family-work route and send those workers into the job module, but do not split that route into work mainly for sale and work mainly for household consumption. GLD therefore counts the unpaid-family-work route as employment in 2021 and 2022.

From 2023 to 2025, the retained data include the market-orientation detail for unpaid family work. In those years, GLD counts unpaid family work as employment only when the activity was mainly for sale. Unpaid family work mainly for household consumption is not counted as employment.

The 2021 and 2022 questionnaires also identify other unpaid workers after the person has not reported unpaid family work. This separate branch should not be read as a sale-versus-own-consumption split for unpaid family workers. In the retained 2022 data, the categories identify volunteer work, unpaid internship or apprenticeship, own-household domestic work, and production for household consumption, not a market-production route.

## Unemployment

Unemployment is assigned only after all employment routes have failed. The EPHPM route is consistent with an ILO-style current unemployment definition: the person is not employed, has search or future-start evidence, and is available to work.

| Unemployment component | Questionnaire definition |
| --- | --- |
| Not employed | The person does not meet any of the employment routes above. |
| Search or business-start effort | The person looked for work or tried to establish a business or farm during the last four weeks. |
| Future starter | The person did not search because work, a business, or a farm activity had already been arranged to start soon. |
| Availability | The person was available immediately or within the survey availability period if work or clients had been obtained. |
| Final unemployment rule | The person is age 15 or above, not employed, either searched or was a future starter, and was available to work. |

## Out of the labor force

Out of the labor force is the residual category after employment and unemployment are assigned. It covers people age 15 and above who do not meet any employment route and also do not meet the unemployment definition. In practice, this includes people who were not employed and either did not search or arrange future work, were not available to work, or otherwise did not satisfy both the search or future-start condition and the availability condition.
