codeunit 5685 "Create Media Repositry"
{
    trigger OnRun()
    begin
        InsertMediaResources();
        InsertExcelTemplates();
    end;

    local procedure InsertMediaResources()
    begin
        InsertMediaResource('CopilotNotAvailable.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));
        InsertMediaResource('ImageAnalysis-Setup-NoText.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));
        InsertMediaResource('OutlookAddinIllustration.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));
        InsertMediaResource('TeamsAppIllustration.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));
        InsertMediaResource('PowerBi-OptIn-480px.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));

        InsertMediaResource('AssistedSetup-NoText-400px.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));
        InsertMediaResource('AssistedSetupDone-NoText-400px.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));
        InsertMediaResource('AssistedSetupInfo-NoText.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));
        InsertMediaResource('ExternalSync-NoText.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));
        InsertMediaResource('FirstInvoice1.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Phone));
        InsertMediaResource('FirstInvoice2.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Phone));
        InsertMediaResource('FirstInvoice3.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Phone));
        InsertMediaResource('FirstInvoiceSplash.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Phone));
        InsertMediaResource('PowerBi-OptIn-480px.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Tablet));
        InsertMediaResource('PowerBi-OptIn-480px.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Phone));
        InsertMediaResource('WhatsNewWizard-Banner-First.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));
        InsertMediaResource('WhatsNewWizard-Banner-Second.png', ImagesSystemFolderLbl, Format(CLIENTTYPE::Web));
    end;


    local procedure InsertExcelTemplates()
    begin
        InsertExcelTemplate('ExcelTemplateBalanceSheet.xltm', ExcelTemplatesFolderLbl);
        InsertExcelTemplate('ExcelTemplateIncomeStatement.xltm', ExcelTemplatesFolderLbl);
        InsertExcelTemplate('ExcelTemplateAgedAccountsPayable.xltm', ExcelTemplatesFolderLbl);
        InsertExcelTemplate('ExcelTemplateAgedAccountsReceivable.xltm', ExcelTemplatesFolderLbl);
        InsertExcelTemplate('ExcelTemplateCashFlowStatement.xltm', ExcelTemplatesFolderLbl);
        InsertExcelTemplate('ExcelTemplateRetainedEarnings.xltm', ExcelTemplatesFolderLbl);
        InsertExcelTemplate('ExcelTemplateTrialBalance.xltm', ExcelTemplatesFolderLbl);
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
        MediaResources.Code := FileName;
        if MediaResources.Insert(true) then;
    end;

    procedure InsertMediaResource(MediaFile: Text[50]; Path: Text[200]; DisplayTarget: Code[50])
    var
        MediaRepository: Record "Media Repository";
        MediaResourcesMgt: Codeunit "Media Resources Mgt.";
        InStream: InStream;
        MediaResourcesCode: Code[50];
    begin
        if MediaRepository.Get(MediaFile, DisplayTarget) then
            exit;

        NavApp.GetResource(Path + MediaFile, InStream);

        MediaRepository.Validate("File Name", MediaFile);
        MediaRepository.Validate("Display Target", DisplayTarget);
        MediaResourcesCode := CopyStr(MediaFile, 1, MaxStrLen(MediaRepository."Media Resources Ref"));
        MediaRepository.Validate("Media Resources Ref", MediaResourcesCode);
        MediaRepository.Insert(true);

        MediaResourcesMgt.InsertMediaFromInstream(MediaResourcesCode, InStream);
    end;

    var
        ImagesSystemFolderLbl: Label 'Images/System/', Locked = true;
        ExcelTemplatesFolderLbl: Label 'ExcelTemplates/', Locked = true;
}