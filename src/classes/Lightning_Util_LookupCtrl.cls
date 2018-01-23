/**
 * (c) Tony Scott. This code is provided as is and without warranty of any kind.
 *
 * This work by Tony Scott is licensed under a Creative Commons Attribution 3.0 Unported License.
 * http://creativecommons.org/licenses/by/3.0/deed.en_US
 */

/**
 * Apex Controller for looking up an SObject via SOSL
 */
public with sharing class Lightning_Util_LookupCtrl {
		/**
		 * Aura enabled method to search a specified SObject for a specific string
		 */
		@AuraEnabled
		public static Result[] lookup(String searchString,
		                              String sObjectAPIName,
		                              String whereClause,
		                              String rawSOQL,
		                              String context) {
				// Sanitze the input
				String sanitizedSearchString=null;
				if(!String.isBlank(searchString)){
					System.debug('>>>searchString: '+searchString);
					sanitizedSearchString = String.escapeSingleQuotes(searchString);
					System.debug('>>>sanitizedSearchString: '+sanitizedSearchString);
					// sanitizedSearchString=sanitizedSearchString.replaceAll('\\\\','\\');
				}
				String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);

				List<Result> results = new List<Result>();
				if(String.isBlank(rawSOQL)) {
						String returningFields = '(id,name)';
						if(String.isNotBlank(whereClause)) {
								returningFields =' (id,name WHERE '+whereClause+') ';
						}

						List<SObject> sobjList=new List<SObject>();
						if(sanitizedSearchString!=null){
							// only 1 search character
							if(sanitizedSearchString.length()==1||sanitizedSearchString=='\\\\'||sanitizedSearchString=='\\\\\\\\'){
								String query='Select Id,Name From '+ sanitizedSObjectAPIName +' Where Name LIKE \'%' + sanitizedSearchString + '%\' limit 20';
								sobjList=Database.query(query);
							}
							// more than 1 search character
							else{
								// Build our SOSL query
								String searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName +returningFields+' Limit 50';

								System.debug('-->searchQuery'+searchQuery);

								// Execute the Query
								List<List<SObject>> searchList = search.query(searchQuery);
								sobjList=searchList[0];
							}
						}
						// empty search character
						else{
							String query='Select Id,Name From '+ sanitizedSObjectAPIName;
							if(String.isNotBlank(whereClause)) {
									query+=' WHERE '+whereClause;
							}
							query+=' Order By Name limit 6';
							sobjList=Database.query(query);
						}

						// Create a list of matches to return
						for (SObject so : sobjList) {
								results.add(new Result((String)so.get('Name'), so.Id));
						}
				}else{

						System.debug('-->rawSOQL'+rawSOQL);
						rawSOQL = rawSOQL.replace('searchString', sanitizedSearchString);
						if(String.isNotBlank(context) && String.isNotBlank(rawSOQL)) {
								//run quieries specific context wise
						}else{
								for(Sobject so : Database.query(rawSOQL)) {
										results.add(new Result((String)so.get('Name'), so.Id));
								}
						}
				}

				return results;
		}

		/**
		 * Inner class to wrap up an SObject Label and its Id
		 */
		public class Result {
				@AuraEnabled public String SObjectLabel {get; set;}
				@AuraEnabled public Id SObjectId {get; set;}

				public Result(String sObjectLabel, Id sObjectId) {
						this.SObjectLabel = sObjectLabel;
						this.SObjectId = sObjectId;
				}
		}
}