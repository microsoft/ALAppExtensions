// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Intrastat;

using Microsoft.DemoTool.Helpers;

codeunit 31493 "Create Transaction Type CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        ImportFromXml();
        InsertTransactionType();
    end;

    local procedure ImportFromXml()
    begin
        NavApp.GetResource(XmlFileTok, FileInStream);
        ImportTransactionTypesCZ.SetSource(FileInStream);
        ImportTransactionTypesCZ.SetThresholdDate(WorkDate());
        ImportTransactionTypesCZ.Import();
    end;

    local procedure InsertTransactionType()
    var
        ContosoIntrastatCZ: Codeunit "Contoso Intrastat CZ";
    begin
        ContosoIntrastatCZ.InsertTransactionType(No11(), No11DescriptionLbl);
        ContosoIntrastatCZ.InsertTransactionType(No21(), No21DescriptionLbl);
    end;

    procedure No11(): Code[10]
    begin
        exit(No11Tok);
    end;

    procedure No21(): Code[10]
    begin
        exit(No21Tok);
    end;

    var
        ImportTransactionTypesCZ: XmlPort "Import Transaction Types CZ";
        FileInStream: InStream;
        XmlFileTok: Label 'trans_i_004.xml', Locked = true;
        No11Tok: Label '11', Locked = true;
        No11DescriptionLbl: Label 'Přímý prodej/nákup s výjimkou přímého obchodu se soukromými spotřebiteli/ze stra', MaxLength = 80, Locked = true;
        No21Tok: Label '21', Locked = true;
        No21DescriptionLbl: Label 'Vrácení zboží', MaxLength = 80, Locked = true;
}