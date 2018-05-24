/*
 * Created by Bartosz Jarmolinski
 * Helper class for DuplicateCheckHandlerv3
 * 
 * v1.1 created on 14/05/2018
 * - added overloaded method FindBestAccountID(List<Account>, Map<Id, Integer>)
*/

public with sharing class DuplicateCheck {

	private String email;
	private String name;
	private String firstName;
	private String lastName;
	private String postCode;
	private String country;
	private String street;
	private String city;
	private String company;

	public DuplicateCheck(String email, String firstName, String lastName, String postCode, String country, String street, String city, String company) {
		this.email = email;
		this.firstName = firstName;
		this.lastName = lastName;
		this.postCode = postCode;
		this.country = country;
		this.street = street;
		this.city = city;
		this.company = company;
		this.name = firstName + ' ' + lastName;
	}
	public Id FindBestAccountID(List<Account> matchingAccounts, Map<Id,Integer> contractCountMap) {
		// the method  returns one account id based on additional match criteria
		Set<Id> accountIdSet = new Set<Id>(); // IDs of matching accounts
		Id recommended;

        for (Account a : matchingAccounts) {
            if (contractCountMap.get(a.Id) > 0 && recommended == NULL) {
                recommended = a.Id;
            }
        }

		// if no account with contract check for the exact match in address
		if (recommended == NULL) {
			recommended = MatchingStreet(street, null, matchingAccounts);
			if (recommended == NULL) {
				recommended = matchingAccounts[0].Id;
			}
		}
		return recommended;
	}
    public Id FindBestAccountID(List<Account> matchingAccounts) {
        // the method  returns one account id based on additional match criteria
        Set<Id> accountIdSet = new Set<Id>(); // IDs of matching accounts
        Id recommended;
        
        for (Account a : matchingAccounts) {
            accountIdSet.add(a.Id);
        }
        
        List<AggregateResult> contractCount = [SELECT AccountId, count(Id) num FROM Contract WHERE AccountId IN :accountIdSet GROUP BY AccountId];
        for (AggregateResult ar : contractCount) {
            if ((Integer) ar.get('num') > 0 && recommended == NULL) {
                recommended = (Id) ar.get('AccountId');
            }
        }
        
        // if no account with contract check for the exact match in address
        if (recommended == NULL) {
            
            recommended = MatchingStreet(street, null, matchingAccounts);
            
            if (recommended == NULL) {
                recommended = matchingAccounts[0].Id;
            }
        }
        return recommended;
    }

	public Id MatchingStreet (String oppBillingStreet, String streetNumber,List<Account> foundAccounts) {

		Decimal matchingRatio;  // used within loop in the logic
		Decimal finalMatchingRatio = 0;  // final value after the loop is over for the specific account
		Id recommended; // account Id with the best finalMatchingRatio
		String numericOutput; // street number

		// assign/extract the number from values passed to the method
		Pattern p = Pattern.compile('[^0-9]');
		if (streetNumber == NULL) {
			numericOutput = p.matcher(oppBillingStreet).replaceAll('');
			System.debug('numeric numericOutput: '+ numericOutput);		
		}
		else {
			numericOutput = streetNumber;
		}

		// match the street
		Pattern p2 = Pattern.compile('[^a-zA-Z .]');
		String textOutput = p2.matcher(oppBillingStreet).replaceAll('');
		System.debug('text output: '+ textOutput);
		List<String>  textOutputArray = textOutput.split('');

		// create map with account as key and matching ratio as as value
		// if number matches, check which string has the best matching ratio
		for (Account a : foundAccounts) {

			String numberToCheck;
			String textToCheck;
			// extract street number from the billing street field of the account
			if (a.BillingStreet != NULL) {
				numberToCheck = p.matcher(a.BillingStreet).replaceAll('');
				//extract street name from the billing street of the account
				textToCheck = p2.matcher(a.BillingStreet).replaceAll('');
				System.debug(numberToCheck);
				System.debug(textToCheck);
			}

			Decimal matchingCount = 0; // count of matching characters
			// split string to individual character

			if(numberToCheck != numericOutput) {
				// go to next iteration if the street number does not match the target value
				//matchingStreetMap.put(a.Id, matchingCount);
				continue;
			}

			List<String> textToCheckArray = textToCheck.split('');
			System.debug(textToCheckArray);
			for(Integer i=0; i < textOutputArray.size(); i++) {
				
				System.debug(i < textToCheckArray.size() && textToCheckArray[i] == textOutputArray[i]);

				if (i < textToCheckArray.size() && textToCheckArray[i] == textOutputArray[i]) {
					matchingCount = matchingCount + 1;
				}
			}
			System.debug(textOutputArray.size());
			matchingRatio = matchingCount / (Decimal) textOutputArray.size();
			Decimal matchingRatioRounded = matchingRatio.setScale(2);
			//matchingStreetMap.put(a.Id, matchingRatioRounded);

			if (matchingRatio > finalMatchingRatio) {
				finalMatchingRatio = matchingRatio;
				recommended = a.Id;
			}
		}
		//return matchingStreetMap;
		return recommended;
	}
}

//# equal Email address
//# equal FistName and LastName 
//# BillingAddress