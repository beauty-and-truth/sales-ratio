# sales-ratio
This project uses publicly-available property sale data for the state of New Jersey to recreate a sales ratio study.

A sales ratio study compares a property’s assessed value against the price paid for it. Property assessments determine property taxes, so you want your property, your township's properties, and your county's properties to be valued correctly compared with their neighbors.  

Sales ratio studies are performed by the state to make sure individuals and townships aren't carrying a disproportionate share of the tax burden. They check:
	1. whether individual properties were assessed correctly
	2. whether individual townships tend to have accurate assessments
	3. what the true property values are 
	4. whether more expensive properties are assessed more or less accurately than less expensive ones

The Sales Ratio is the Assessment Value divided by its Sales Price. Sales ratios are analyzed for outliers and errors, corrected, and adjusted for market trends before they are used to validate assessments.


## Sources

For this project, I took property sale records for every county in New Jersey from this Monmouth County site:

http://tax1.co.monmouth.nj.us/cgi-bin/prc6.cgi?menu=index&ms_user=glou&district=0801&mode=11

And I recreated the sales ratio study used by the Minnesota Department of Revenue, as described here:

https://www.revenue.state.mn.us/sales-ratio-studies

To interpret the column names, I used: https://www.state.nj.us/treasury/taxation/pdf/lpt/SR1A_FileLayout_Description.pdf

and for U-N-Code interpretation: https://www.state.nj.us/treasury/taxation/pdf/lpt/guidelines33.pdf


