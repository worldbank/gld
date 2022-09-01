# Labor force status

The Thailand NSO reports unemployment to include individuals that are either seeking work **or** available for work. In contrast, the GLD defines the unemployed as those who are seeking **and** available for work. The `lstatus` variable codes individuals who are (a) seeking but not available for work and (b) not seeking but available for work as not in the labor force, while based on the NSO definition, these groups are included in the unemployed population. 

Groups (a) and (b) are covered in GLD as a special subgroup of those out of the labour force, namely as the *potential labour force*. They are coded in the variable `potential_lf`

![image](utilities/lstatus_definition.png)

In other words, the THA NSO unemployed is equal to the sum of the GLD unemployed + potential labor force (LF) as a fraction of the sum of the labor force population and the potential labor force population. The line graph below confirms that the Thailand NSO unemployment numbers can be derived based on this formula.

![image](utilities/tha_gld_unemployment.png?raw=true)
