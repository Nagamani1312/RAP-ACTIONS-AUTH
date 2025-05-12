@AccessControl.authorizationCheck:#NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_NM_TABLETMG
  as select from znm_table as Student
{
  key studentid as Studentid,
  firstname as Firstname,
  lastname as Lastname,
  age as Age,
  course as Course,
  courseduration as Courseduration,
  status as Status,
  gender as Gender,
  
  dob as Dob,
  @Semantics.user.createdBy: true
  local_created_by as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  local_created_at as LocalCreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt
  
}
