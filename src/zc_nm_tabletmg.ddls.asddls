@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_NM_TABLETMG
  provider contract transactional_query
  as projection on ZR_NM_TABLETMG
{
  key Studentid,
 
  Firstname,
  Lastname,
  Age,
  Course,
  Courseduration,
  Status,
  //@Consumption.filter.defaultValue: 'Female'
  Gender,
  Dob,
  LocalCreatedBy,
  LocalCreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  LastChangedAt
  
}
