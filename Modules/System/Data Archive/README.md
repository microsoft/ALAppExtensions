Provides an API that lets you add archiving to any app object that needs to archive data before deleting it. 
This API is in itself functionless, but relies on an implementation of the interface. As default, this is handled by a first-party preinstalled app, "Data Archive".

BaseApp and other apps will use this basic code flow:

~~~
procedure Foo()
var 
    DataArchive: Codeunit "Data Archive";  // System App
    Customer: Record Customer;
    RecRef: RecordRef;
    NewArchiveNo: Integer;
begin
    ...
    NewArchiveNo := DataArchiveInterface.Create('New Archive');
    ...
    RecRef.GetTable(Customer);
    DataArchiveInterface.SaveRecord(RecRef);
    ...
    DataArchiveInterface.Save();
    ...
end;
~~~


### Data Archive
This codeunit is the API for this feature and holds functions for creating/reopening an archive, saving a single record or a recordset, and either saving or discarding the archive.
It also enables turning on subscription for all delete operations, hence creating a 'recorder' of deleted data.

