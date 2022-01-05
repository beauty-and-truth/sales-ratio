# sales-ratio
 Analysis of the relationship between property sales prices and property assessments

Sales ratio studies compare property assessments and property sales prices to determine
	1. whether individual properties were assessed correctly
	2. whether individual townships tend to have accurate assessments
	3. what the true property values are (which affects tax revenue)
	4. whether more expensive properties are assessed more or less accurately than cheaper properties

The naive Sales Ratio is the Assessment Value divided by its Sales Price. Sales ratios are analyzed for outliers and errors, corrected, and adjusted for market trends before they are used to validate assessments.

This project uses publicly-available property sale data for the state of New Jersey to recreate a sales ratio study.

## Sources

For this project, I took property sale records for every county in New Jersey from this Monmouth County site:

http://tax1.co.monmouth.nj.us/cgi-bin/prc6.cgi?menu=index&ms_user=glou&district=0801&mode=11

And I recreated the sales ratio study used by the Minnesota Department of Revenue, as described here:

https://www.revenue.state.mn.us/sales-ratio-studies

To interpret the column names, I used: https://www.state.nj.us/treasury/taxation/pdf/lpt/SR1A_FileLayout_Description.pdf

and for U-N-Code interpretation: https://www.state.nj.us/treasury/taxation/pdf/lpt/guidelines33.pdf


