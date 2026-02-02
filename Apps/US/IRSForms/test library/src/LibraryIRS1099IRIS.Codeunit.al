// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Bank.BankAccount;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Vendor;
using System.Utilities;

codeunit 148023 "Library - IRS 1099 IRIS"
{
    var
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";

    #region Company
    procedure InitializeCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
        PostCode: Record "Post Code";
    begin
        PostCode.Validate(Code, '60402');
        PostCode.Validate(City, 'Berwyn');
        PostCode.Validate(County, 'IL');
        PostCode.Validate("Country/Region Code", 'US');
        PostCode.Insert();
        CompanyInformation.Get();
        CompanyInformation.Name := LibraryUtility.GenerateGUID();
        CompanyInformation."Federal ID No." := '00-0123456';
        CompanyInformation.Validate("Post Code", PostCode.Code);
        CompanyInformation.Address := '6201 Roosevelt Rd';
        CompanyInformation.Modify();
    end;

    procedure InitializeIRSFormsSetup()
    var
        CompanyInformation: Record "Company Information";
        IRSFormsSetup: Record "IRS Forms Setup";
    begin
        CompanyInformation.Get();
        IRSFormsSetup.InitSetup();
        IRSFormsSetup.Validate("Business Name Control", CopyStr(CompanyInformation.Name, 1, 4));
        IRSFormsSetup.Implementation := "IRS Forms Implementation"::Test;
        IRSFormsSetup.Modify(true);
    end;
    #endregion Company

    #region Transmission
    procedure CreateTransmission(var Transmission: Record "Transmission IRIS"; PeriodNo: Code[20])
    var
        IRSFormsFacade: Codeunit "IRS Forms Facade";
        ReportingYear: Code[4];
    begin
        ReportingYear := CopyStr(PeriodNo, 1, 4);
        IRSFormsFacade.CreateTransmission(Transmission, ReportingYear);
        Transmission.SetRange("Period No.", ReportingYear);
        Transmission.FindFirst();
    end;

    procedure CreateTransmissionXmlContent(Transmission: Record "Transmission IRIS"; TransmissionType: Enum "Transmission Type IRIS"; IsTest: Boolean; var UniqueTransmissionId: Text[100]; var TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary; var TempBlob: Codeunit "Temp Blob")
    var
        IRSFormsFacade: Codeunit "IRS Forms Facade";
    begin
        IRSFormsFacade.CreateTransmissionXmlContent(Transmission, TransmissionType, IsTest, UniqueTransmissionId, TempIRS1099FormDocHeader, TempBlob);
    end;

    procedure DeleteAllTransmissions()
    var
        Transmission: Record "Transmission IRIS";
        TransmissionLog: Record "Transmission Log IRIS";
        TransmissionLogLine: Record "Transmission Log Line IRIS";
    begin
        TransmissionLogLine.DeleteAll(true);
        TransmissionLog.DeleteAll(true);
        Transmission.ModifyAll(Status, Enum::"Transmission Status IRIS"::None);
        Transmission.DeleteAll(true);
    end;
    #endregion Transmission

    #region Vendor
    procedure CreateUSVendor(var Vendor: Record Vendor)
    begin
        CreateVendor(Vendor, 'US', 'IL');
    end;

    procedure CreateVendor(var Vendor: Record Vendor; CountryRegionCode: Code[10]; ProvinceOrStateName: Text[30])
    var
        PostCode: Record "Post Code";
        PaymentMethod: Record "Payment Method";
    begin
        PostCode.Validate(Code, LibraryUtility.GenerateRandomNumericText(5));
        PostCode.Validate(City, LibraryUtility.GenerateGUID());
        PostCode.Validate(County, ProvinceOrStateName);
        PostCode.Validate("Country/Region Code", CountryRegionCode);
        PostCode.Insert();

        LibraryERM.CreatePaymentMethodWithBalAccount(PaymentMethod);

        Vendor.Get(LibraryPurchase.CreateVendorNo());
        Vendor."Federal ID No." := '00-0654321';
        Vendor.Validate("Post Code", PostCode.Code);
        Vendor.Validate(Address, LibraryUtility.GenerateGUID());
        Vendor.Validate("Payment Method Code", PaymentMethod.Code);     // CASH payment method
        Vendor.Modify();
    end;
    #endregion Vendor
}
