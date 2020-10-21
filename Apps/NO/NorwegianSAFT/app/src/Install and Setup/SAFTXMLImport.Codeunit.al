codeunit 10671 "SAF-T XML Import"
{
    Permissions = TableData 2000000182 = rimd;
    TableNo = "SAF-T Mapping Range";

    var
        ImportingSourceForMappingLbl: Label 'Importing source for mapping...';
        NotPossibleToFindXMLFilesForMappingTypeErr: Label 'Not possible to find the XML files for mapping type %1', Comment = '%1 = a mapping type, one of the following - SAF-T Standard Account, Income Statement';
        NotPossibleToParseMappingXMLFileErr: Label 'Not possible to parse XML file with %1 for mapping', Comment = '%1 = a mapping type, one of the following - SAF-T Standard Account, Income Statement';
        MappingFileNotLoadedErr: Label 'Mapping source file %1 was not loaded. Choose the Import the Source Files For Mapping action and import one or more mapping source files.', Comment = '%1 = file name, like StandardVATCodes.xml';
        NoMappingSourceIdentifiedErr: Label 'Not possible to identify mapping source type %1. Open a SAF-T Mapping Source page and import source file with such type', Comment = '%1 = possible values: Two Digit Standard Account, Four Digit Standard Account, Income Statement, Standard Tax Code';
        SAFTStandardAccountsTxt: Label 'SAF-T Standard Accounts';
        SAFTGroupingCodesTxt: Label 'SAF-T Grouping Codes';
        SAFTTaxCodeTxt: Label 'SAF-T Tax Codes';
        SelectMappingTxt: Label 'Select an XML file with SAF-T codes for mapping';
        NATxt: Label 'NA', Comment = 'Abbreviation from Not Applicable';
        NotApplicableTxt: Label 'Not applicable';
        AssetsLbl: Label 'Assets';
        LiabilityAndCapitalLbl: Label 'Liability and capital';
        RevenueLbl: Label 'Revenue';
        PurchaseLbl: Label 'Purchase';
        SaleriesAndHRCostsLbl: Label 'Salaries and HR Costs';
        OtherCostsLbl: Label 'Other costs';
        FinanceLbl: Label 'Finance';
        CannotFindCategotyForStdAccErr: Label 'Not possible to find category for standard account %1', Comment = '%1 - standard account no.';
        MediaResourceNoContentErr: Label 'Media resource %1 has not content. Open the SAF-T Mapping Source page and choose the Update action on selected media resource code.', Comment = 'File name, like GeneralLedgerAccounts.xml';

    trigger OnRun()
    var
        Window: Dialog;
    begin
        if GuiAllowed() then
            Window.Open(ImportingSourceForMappingLbl);
        ImportMappingData(Rec);
        ImportStandardVATCodes();
        iF GuiAllowed() then
            Window.Close();
    end;

    local procedure ImportMappingData(SAFTMappingRange: Record "SAF-T Mapping Range")
    var
        TempMediaResources: Record "Media Resources" temporary;
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        CopyMediaResourceToTempFromMappingSources(TempMediaResources, SAFTMappingRange.GetSAFTMappingSourceTypeByMappingType(), false);
        if not TempMediaResources.FindSet() then
            error(NotPossibleToFindXMLFilesForMappingTypeErr, format(SAFTMappingRange."Mapping Type"));
        repeat
            FillXMLBufferFromMediaResource(TempXMLBuffer, TempMediaResources);
            Case SAFTMappingRange."Mapping Type" of
                SAFTMappingRange."Mapping Type"::"Two Digit Standard Account", SAFTMappingRange."Mapping Type"::"Four Digit Standard Account":
                    ImportStandardAccountsFromXMLBuffer(TempXMLBuffer, SAFTMappingRange."Mapping Type");
                SAFTMappingRange."Mapping Type"::"Income Statement":
                    ImportGroupingCodesFromXMLBuffer(TempXMLBuffer);
            end;
        until TempMediaResources.Next() = 0;
    end;

    procedure ImportFromMappingSource(SAFTMappingSource: Record "SAF-T Mapping Source")
    var
        TempMediaResources: Record "Media Resources" temporary;
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        CopyMediaResourceToTempFromMappingSource(TempMediaResources, SAFTMappingSource);
        FillXMLBufferFromMediaResource(TempXMLBuffer, TempMediaResources);
        Case SAFTMappingSource."Source Type" of
            SAFTMappingSource."Source Type"::"Two Digit Standard Account", SAFTMappingSource."Source Type"::"Four Digit Standard Account":
                ImportStandardAccountsFromXMLBuffer(TempXMLBuffer, GetMappingTypeBySourceType(SAFTMappingSource."Source Type"));
            SAFTMappingSource."Source Type"::"Income Statement":
                ImportGroupingCodesFromXMLBuffer(TempXMLBuffer);
            SAFTMappingSource."Source Type"::"Standard Tax Code":
                ImportStandardVATCodesFromXMLBuffer(TempXMLBuffer);
        end;
    end;

    procedure ImportStandardVATCodes()
    var
        TempMediaResources: Record "Media Resources" temporary;
        TempXMLBuffer: Record "XML Buffer" temporary;
        SAFTSetup: Record "SAF-T Setup";
        SAFTMappingSourceType: Enum "SAF-T Mapping Source Type";
    begin
        CopyMediaResourceToTempFromMappingSources(TempMediaResources, SAFTMappingSourceType::"Standard Tax Code", false);
        FillXMLBufferFromMediaResource(TempXMLBuffer, TempMediaResources);
        ImportStandardVATCodesFromXMLBuffer(TempXMLBuffer);
        SAFTSetup.Get();
        SAFTSetup.Validate("Not Applicable VAT Code", InsertNotApplicableVATCode());
        SAFTSetup.Modify(true);
    end;

    procedure MappingSourceLoaded(SAFTMappingRange: Record "SAF-T Mapping Range"): Boolean
    var
        TempMediaResources: Record "Media Resources" temporary;
        SAFTMappingSourceType: Enum "SAF-T Mapping Source Type";
    begin
        exit(
            CopyMediaResourceToTempFromMappingSources(TempMediaResources, SAFTMappingRange.GetSAFTMappingSourceTypeByMappingType(), true) and
            CopyMediaResourceToTempFromMappingSources(TempMediaResources, SAFTMappingSourceType::"Standard Tax Code", true));
    end;

    local procedure ImportStandardVATCodesFromXMLBuffer(var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        TempChildXMLBuffer: Record "XML Buffer" temporary;
        VATCode: Record "VAT Code";
    begin
        if not TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, '/StandardTaxCodes/TaxCode') then
            Error(NotPossibleToParseMappingXMLFileErr, SAFTTaxCodeTxt);
        repeat
            if not TempXMLBuffer.HasChildNodes() then
                Error(NotPossibleToParseMappingXMLFileErr, SAFTTaxCodeTxt);
            TempXMLBuffer.FindChildElements(TempChildXMLBuffer);
            VATCode.Init();
            VATCode.Code := CopyStr(TempChildXMLBuffer.Value, 1, MaxStrLen(VATCode.Code));
            TempChildXMLBuffer.Next();
            VATCode.Description := copystr(TempChildXMLBuffer.Value, 1, MaxStrLen(VATCode.Description));
            TempChildXMLBuffer.Next(); // skip eng description
            TempChildXMLBuffer.Next();
            If TempChildXMLBuffer.Name = 'TaxRate' then
                TempChildXMLBuffer.Next();
            if TempChildXMLBuffer.Name = 'Compensation' then
                Evaluate(VATCode.Compensation, TempChildXMLBuffer.Value);
            if VATCode.insert() then;
        until TempXMLBuffer.Next() = 0;
    end;

    local procedure ImportStandardAccountsFromXMLBuffer(var TempXMLBuffer: Record "XML Buffer" temporary; MappingType: Enum "SAF-T Mapping Type")
    var
        TempChildXMLBuffer: Record "XML Buffer" temporary;
        SAFTMapping: Record "SAF-T Mapping";
        StdAccNo: Code[20];
    begin
        if not TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, '/StandardAccounts/Account') then
            Error(NotPossibleToParseMappingXMLFileErr, SAFTStandardAccountsTxt);
        repeat
            if not TempXMLBuffer.HasChildNodes() then
                Error(NotPossibleToParseMappingXMLFileErr, SAFTStandardAccountsTxt);
            TempXMLBuffer.FindChildElements(TempChildXMLBuffer);
            if (strlen(TempChildXMLBuffer.Value) > 4) then
                Error('Standard account id must not has length more than 4 chars');
            StdAccNo := CopyStr(TempChildXMLBuffer.Value, 1, MaxStrLen(SAFTMapping."No."));
            SAFTMapping.Init();
            SAFTMapping."Mapping Type" := MappingType;
            SAFTMapping."Category No." := TryInsertCategoryForStandardAccount(SAFTMapping."Mapping Type", StdAccNo);
            SAFTMapping."No." := StdAccNo;
            TempChildXMLBuffer.Next();
            SAFTMapping.Description := copystr(TempChildXMLBuffer.Value, 1, MaxStrLen(SAFTMapping.Description));
            if SAFTMapping.insert() then;
        until TempXMLBuffer.Next() = 0;
        InsertNotApplicationMappingCode(MappingType);
    end;

    local procedure InsertNotApplicationMappingCode(MappingType: Enum "SAF-T Mapping Type")
    var
        SAFTMapping: Record "SAF-T Mapping";
    begin
        SAFTMapping.Init();
        SAFTMapping."Mapping Type" := MappingType;
        SAFTMapping."Category No." := TryInsertSAFTMappingCategory(MappingType, NATxt, NotApplicableTxt);
        SAFTMapping."No." := NATxt;
        SAFTMapping.Description := NotApplicableTxt;
        if SAFTMapping.Insert() then;
    end;

    local procedure InsertNotApplicableVATCode(): Code[10]
    var
        VATCode: Record "VAT Code";
    begin
        VATCode.Init();
        VATCode.Code := NATxt;
        VATCode.Description := NotApplicableTxt;
        if not VATCode.Insert() then;
        exit(VATCode.Code)
    end;

    local procedure ImportGroupingCodesFromXMLBuffer(var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        SAFTMappingCategory: Record "SAF-T Mapping Category";
        SAFTMapping: Record "SAF-T Mapping";
        TempChildXMLBuffer: Record "XML Buffer" temporary;
        CategoryCode: Code[20];
    begin
        if not TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, '/GroupingCategoryCode/Account') then
            Error(NotPossibleToParseMappingXMLFileErr, SAFTGroupingCodesTxt);
        repeat
            if not TempXMLBuffer.HasChildNodes() then
                Error(NotPossibleToParseMappingXMLFileErr, SAFTGroupingCodesTxt);
            TempXMLBuffer.FindChildElements(TempChildXMLBuffer);
            CategoryCode := CopyStr(TempChildXMLBuffer.Value, 1, MaxStrLen(CategoryCode));
            if CategoryCode <> SAFTMappingCategory."No." then begin
                SAFTMappingCategory.Init();
                SAFTMappingCategory."Mapping Type" := SAFTMappingCategory."Mapping Type"::"Income Statement";
                SAFTMappingCategory."No." := CategoryCode;
                TempChildXMLBuffer.Next();
                SAFTMappingCategory.Description := CopyStr(TempChildXMLBuffer.Value, 1, MaxStrLen(SAFTMappingCategory.Description));
                if not SAFTMappingCategory.insert() then
                    SAFTMappingCategory.Modify();
            end else
                TempChildXMLBuffer.Next();

            SAFTMapping.Init();
            SAFTMapping."Mapping Type" := SAFTMapping."Mapping Type"::"Income Statement";
            SAFTMapping."Category No." := SAFTMappingCategory."No.";
            TempChildXMLBuffer.Next();
            if TempChildXMLBuffer.Name = 'CategoryDescription' then
                TempChildXMLBuffer.Next();
            SAFTMapping."No." := CopyStr(TempChildXMLBuffer.Value, 1, MaxStrLen(SAFTMapping."No."));
            TempChildXMLBuffer.Next();
            SAFTMapping.Description := CopyStr(TempChildXMLBuffer.Value, 1, MaxStrLen(SAFTMapping.Description));
            if not SAFTMapping.insert() then
                SAFTMapping.Modify();
        until TempXMLBuffer.Next() = 0;
        InsertNotApplicationMappingCode(SAFTMapping."Mapping Type");
    end;

    local procedure CopyMediaResourceToTempFromMappingSources(var TempMediaResource: Record "Media Resources" temporary; SAFTMappingSourceType: Enum "SAF-T Mapping Source Type"; CheckOnly: Boolean) MappingSourceFileLoaded: Boolean;
    var
        MediaResources: Record "Media Resources";
        SAFTMappingSource: Record "SAF-T Mapping Source";
    begin
        SAFTMappingSource.SetRange("Source Type", SAFTMappingSourceType);
        if not SAFTMappingSource.FindSet() then begin
            if CheckOnly then
                exit(false);
            error(NoMappingSourceIdentifiedErr, Format(SAFTMappingSourceType));
        end;
        repeat
            MappingSourceFileLoaded := false;
            if MediaResources.Get(SAFTMappingSource."Source No.") then begin
                MediaResources.CalcFields(Blob);
                if MediaResources.Blob.HasValue() then begin
                    TempMediaResource.Init();
                    TempMediaResource := MediaResources;
                    if not TempMediaResource.Find() then
                        TempMediaResource.Insert();
                    MappingSourceFileLoaded := true;
                end;
            end;
            if (not MappingSourceFileLoaded) and (not CheckOnly) then
                error(MappingFileNotLoadedErr, SAFTMappingSource."Source No.");
        until SAFTMappingSource.Next() = 0;
        exit(MappingSourceFileLoaded);
    end;

    local procedure CopyMediaResourceToTempFromMappingSource(var TempMediaResource: Record "Media Resources" temporary; SAFTMappingSource: Record "SAF-T Mapping Source")
    var
        MediaResources: Record "Media Resources";
    begin
        if not MediaResources.Get(SAFTMappingSource."Source No.") then
            error(MappingFileNotLoadedErr, SAFTMappingSource."Source No.");
        MediaResources.CalcFields(Blob);
        TempMediaResource.Init();
        TempMediaResource := MediaResources;
        if not TempMediaResource.Find() then
            TempMediaResource.Insert();
    end;

    local procedure FillXMLBufferFromMediaResource(var TempXMLBuffer: Record "XML Buffer" temporary; var TempMediaResources: Record "Media Resources" temporary)
    var
        MediaResourcesMgt: Codeunit "Media Resources Mgt.";
        XMLText: Text;
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.DeleteAll();
        XMLText := MediaResourcesMgt.ReadTextFromMediaResource(TempMediaResources.Code);
        if XMLText = '' then
            Error(MediaResourceNoContentErr, TempMediaResources.Code);
        TempXMLBuffer.LoadFromText(XMLText);
    end;

    procedure ImportXmlFileIntoMediaResources(var MediaResources: Record "Media Resources")
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        ImportFileInStream: InStream;
        ImportFileOutStream: OutStream;
        ClientFileName: Text;
    begin
        ClientFileName := FileManagement.BLOBImportWithFilter(TempBlob, SelectMappingTxt, '', 'XML file (*.xml)|*.xml', 'xml');
        if ClientFileName = '' then
            exit;

        MediaResources.Init();
        MediaResources.Code :=
            COPYSTR(FileManagement.GetFileName(ClientFileName), 1, MAXSTRLEN(MediaResources.Code));
        if MediaResources.Find() then
            MediaResources.Delete();

        TempBlob.CreateInStream(ImportFileInStream);
        MediaResources.Blob.CreateOutStream(ImportFileOutStream);
        CopyStream(ImportFileOutStream, ImportFileInStream);
        MediaResources.Insert();
    end;

    local procedure GetMappingTypeBySourceType(SourceType: Enum "SAF-T Mapping Source Type") MappingType: Enum "SAF-T Mapping Type"
    begin
        case SourceType of
            SourceType::"Two Digit Standard Account":
                exit(MappingType::"Two Digit Standard Account");
            SourceType::"Four Digit Standard Account":
                exit(MappingType::"Four Digit Standard Account");
        end;
    end;

    local procedure TryInsertCategoryForStandardAccount(MappingType: Enum "SAF-T Mapping Type"; StdAccNo: Code[20]): Code[20]
    var
        CategoryNo: COde[20];
    begin
        CategoryNo := copystr(StdAccNo, 1, 1);
        case CategoryNo of
            '1':
                exit(TryInsertSAFTMappingCategory(MappingType, CategoryNo, AssetsLbl));
            '2':
                exit(TryInsertSAFTMappingCategory(MappingType, CategoryNo, LiabilityAndCapitalLbl));
            '3':
                exit(TryInsertSAFTMappingCategory(MappingType, CategoryNo, RevenueLbl));
            '4':
                exit(TryInsertSAFTMappingCategory(MappingType, CategoryNo, PurchaseLbl));
            '5':
                exit(TryInsertSAFTMappingCategory(MappingType, CategoryNo, SaleriesAndHRCostsLbl));
            '6', '7':
                exit(TryInsertSAFTMappingCategory(MappingType, CategoryNo, OtherCostsLbl));
            '8':
                exit(TryInsertSAFTMappingCategory(MappingType, CategoryNo, FinanceLbl));
            else
                error(CannotFindCategotyForStdAccErr, StdAccNo);
        end;
    end;

    local procedure TryInsertSAFTMappingCategory(MappingType: Enum "SAF-T Mapping Type"; CategoryNo: Code[20]; Description: Text[250]): Code[20]
    var
        SAFTMappingCategory: Record "SAF-T Mapping Category";
    begin
        SAFTMappingCategory.Init();
        SAFTMappingCategory."Mapping Type" := MappingType;
        SAFTMappingCategory."No." := CategoryNo;
        SAFTMappingCategory.Description := Description;
        if not SAFTMappingCategory.insert() then
            SAFTMappingCategory.modify();
        exit(SAFTMappingCategory."No.");
    end;
}
