The module provides a page to select application objects.

Usage example:

```
procedure SelectPage(var Result: Record AllObjWithCaption): Boolean
var
    AllObjects: Record AllObjWithCaption;
    ObjType: Option TableData,Table,,Report,,Codeunit,XMLport,MenuSuite,Page,Query,System,FieldNumber;
    Objects: Page Objects;
begin
    // Filter the table to consist of only pages
    AllObjects.FilterGroup(2);
    AllObjects.SetRange("Object Type", ObjType::Page);
    AllObjects.FilterGroup(0);

    Objects.SetRecord(AllObjects);
    Objects.SetTableView(AllObjects);
    Objects.LookupMode := true;

    if Objects.RunModal = ACTION::LookupOK then begin
        Objects.GetRecord(Result);
        exit(true);
    end;

    exit(false);
end;
```


# Public Objects
## Objects (Page 358)

 List page that contains all of the application objects.
 

