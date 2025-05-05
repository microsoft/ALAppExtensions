// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.Foundation.Company;
using Microsoft.DemoTool;
using Microsoft.DemoTool.Helpers;

codeunit 5228 "Create Company Information"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Company Information" = rim,
        tabledata "O365 Brand Color" = rimd;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoCompany: Codeunit "Contoso Company";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        ContosoCompany.SetOverwriteData(true);
        CreateSetupCompany();
        ContosoCompany.InsertCompanyInformation(DefaultCronusCompanyName(), '5 The Ring', 'Westminster', ContosoCoffeeDemoDataSetup."Country/Region Code", 'W2 8HG', 'London', 'Adam Matteson', '0666-666-6666', '0666-666-6660', '888-9999', 'World Wide Bank', 'BG99999', '99-99-888', 'GB 12 CPBK 08929965044991', '99-99-999', '777777777', DefaultCronusCompanyName(), '5 The Ring', 'Westminster', ContosoCoffeeDemoDataSetup."Country/Region Code", 'W2 8HG', 'London', 'todo:picturename', '<90D>');

        AddDefaultCompanyPicture();
    end;

    local procedure AddDefaultCompanyPicture()
    var
        CompanyInformation: Record "Company Information";
        InStream: InStream;
        OutStream: OutStream;
    begin
        CompanyInformation.Get();

        NavApp.GetResource('CRONUS.jpg', InStream);
        CompanyInformation.Picture.CreateOutStream(OutStream);
        CopyStream(OutStream, InStream);
        CompanyInformation.Modify(true);
    end;

    procedure DefaultCronusCompanyName(): Text[100]
    var
        CompanyInformation: Record "Company Information";
    begin
        if CompanyInformation.Get() then
            if CompanyInformation.Name <> '' then
                exit(CompanyInformation.Name);

        exit('CRONUS International Ltd.');
    end;

    procedure DefaultCompanyVATRegistrationNo(): Text[20]
    var
        CompanyInformation: Record "Company Information";
    begin
        if CompanyInformation.Get() then
            if CompanyInformation."VAT Registration No." <> '' then
                exit(CompanyInformation."VAT Registration No.");

        exit('777777777');
    end;

    internal procedure CreateSetupCompany()
    var
        O365BrandColor, DefaultColor : Record "O365 Brand Color";
        CompanyInformation: Record "Company Information";
    begin
        O365BrandColor.DeleteAll();
        O365BrandColor.CreateDefaultBrandColors();
        // when color value is empty, we get the default color (blue)
        O365BrandColor.FindColor(DefaultColor, '');

        if not CompanyInformation.Get() then
            CompanyInformation.Insert();

        CompanyInformation.Validate("Brand Color Code", DefaultColor.Code);
        CompanyInformation.Modify(true);
    end;
}
