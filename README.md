# Project_Evidence


The basic status:  
 I want to hold the members and the datas in a record.
 Datas:
	- address - index

	- hash1
	- hash2
	- timelimit

maybe more datas: 
	- status
	- discount
	- etc...

I want to get back the datas from user ID. Update: I use the address to index of the record


Plan: 
- just the members can send ether to the contarct --> made onlyMember modifier

- from the amount of ether i want to calculate the timelimit --> ok ( the counting is wrong)

- I want to know an address is a member or not? --> isMember:true/false done

- I want to host from the member a signal "OK" 

- delete a record -- > if we have status we dont need to delete

- know how much memebrs we have --> I know how much record we have

- maybe later change the timelimit --> updateTimelimit done

- one address -more record , more hosted URL  --> back to one , 
now the multiple record doeasnt work, so its need to do again






 
