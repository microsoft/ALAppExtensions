codeunit 5398 "Create Excel Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        FolderNameLbl: Label 'ExcelTemplates', Locked = true;
    begin
        InsertExcelTemplate('ExcelTemplateBalanceSheet.xltm', FolderNameLbl + '/');
        InsertExcelTemplate('ExcelTemplateIncomeStatement.xltm', FolderNameLbl + '/');
        InsertExcelTemplate('ExcelTemplateAgedAccountsPayable.xltm', FolderNameLbl + '/');
        InsertExcelTemplate('ExcelTemplateAgedAccountsReceivable.xltm', FolderNameLbl + '/');
        InsertExcelTemplate('ExcelTemplateCashFlowStatement.xltm', FolderNameLbl + '/');
        InsertExcelTemplate('ExcelTemplateRetainedEarnings.xltm', FolderNameLbl + '/');
        InsertExcelTemplate('ExcelTemplateTrialBalance.xltm', FolderNameLbl + '/');
    end;

    procedure InsertExcelTemplate(FileName: Text[50]; PathToFile: Text)
    var
        MediaResources: Record "Media Resources";
        InStream: InStream;
        OutStream: OutStream;
    begin
        if MediaResources.Get(FileName) then
            exit;

        NavApp.GetResource(PathToFile + FileName, InStream);
        MediaResources.Blob.CreateOutStream(OutStream);
        CopyStream(OutStream, InStream);
        MediaResources.Insert(true);
    end;
}