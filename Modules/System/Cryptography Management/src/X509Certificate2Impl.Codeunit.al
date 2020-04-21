// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1285 "X509Certificate2 Impl."
{
    Access = Internal;

    var
        CertInitializeErr: Label 'Unable to initialize certificate!';

    procedure VerifyCertificate(var CertBase64Value: Text; Password: Text; ContentType: Enum "X509 Content Type"): Boolean
    var
        X509Certificate2: DotNet X509Certificate2;
    begin
        if not TryInitializeCertificate(CertBase64Value, Password, X509Certificate2) then
            Error(CertInitializeErr);
        if not TryExportToBase64String(X509Certificate2, ContentType, CertBase64Value) then
            Error(GetLastErrorText());
        exit(true);
    end;

    procedure GetCertificateFriendlyName(CertBase64Value: Text; var FriendlyName: Text)
    var
        X509Certificate2: DotNet X509Certificate2;
    begin
        CreateX509Certificate(CertBase64Value, X509Certificate2);
        FriendlyName := X509Certificate2.FriendlyName();
    end;

    procedure GetCertificateThumbprint(CertBase64Value: Text; var Thumbprint: Text)
    var
        X509Certificate2: DotNet X509Certificate2;
    begin
        CreateX509Certificate(CertBase64Value, X509Certificate2);
        Thumbprint := X509Certificate2.Thumbprint();
    end;

    procedure GetCertificateIssuer(CertBase64Value: Text; var Issuer: Text)
    var
        X509Certificate2: DotNet X509Certificate2;
    begin
        CreateX509Certificate(CertBase64Value, X509Certificate2);
        Issuer := X509Certificate2.Issuer();
    end;

    procedure GetCertificateExpiration(CertBase64Value: Text; var Expiration: DateTime)
    var
        X509Certificate2: DotNet X509Certificate2;
    begin
        CreateX509Certificate(CertBase64Value, X509Certificate2);
        Evaluate(Expiration, X509Certificate2.GetExpirationDateString());
    end;

    procedure GetCertificateNotBefore(CertBase64Value: Text; var NotBefore: DateTime)
    var
        X509Certificate2: DotNet X509Certificate2;
    begin
        CreateX509Certificate(CertBase64Value, X509Certificate2);
        Evaluate(NotBefore, X509Certificate2.GetEffectiveDateString());
    end;

    procedure HasPrivateKey(CertBase64Value: Text): Boolean
    var
        X509Certificate2: DotNet X509Certificate2;
    begin
        CreateX509Certificate(CertBase64Value, X509Certificate2);
        exit(X509Certificate2.HasPrivateKey());
    end;

    procedure GetCertificatePropertiesAsJson(CertBase64Value: Text; var CertPropertyJson: Text)
    var
        X509Certificate2: DotNet X509Certificate2;
    begin
        CreateX509Certificate(CertBase64Value, X509Certificate2);
        CreateCertificatePropertyJson(X509Certificate2, CertPropertyJson);
    end;

    [TryFunction]
    local procedure TryInitializeCertificate(CertBase64Value: Text; Password: Text; var X509Certificate2: DotNet X509Certificate2)
    var
        X509KeyStorageFlags: DotNet X509KeyStorageFlags;
        Convert: DotNet Convert;
    begin
        X509Certificate2 := X509Certificate2.X509Certificate2(Convert.FromBase64String(CertBase64Value), Password, X509KeyStorageFlags.Exportable);
        if IsNull(X509Certificate2) then
            Error('');
    end;

    [TryFunction]
    local procedure TryExportToBase64String(X509Certificate2: DotNet X509Certificate2; ContentType: Enum "X509 Content Type"; var CertBase64Value: Text)
    var
        Convert: DotNet Convert;
        X509ContentType: DotNet X509ContentType;
        Enum: DotNet Enum;
    begin
        X509ContentType := Enum.Parse(GetDotNetType(X509ContentType), Format(ContentType));
        CertBase64Value := Convert.ToBase64String(X509Certificate2.Export(X509ContentType));
    end;

    local procedure CreateX509Certificate(CertBase64Value: Text; var X509Certificate2: DotNet X509Certificate2)
    var
        Convert: DotNet Convert;
    begin
        X509Certificate2 := X509Certificate2.X509Certificate2(Convert.FromBase64String(CertBase64Value));
    end;

    local procedure CreateCertificatePropertyJson(X509Certificate2: DotNet X509Certificate2; var CertPropertyJson: Text)
    var
        JObject: JsonObject;
        PropertyInfo: DotNet PropertyInfo;
    begin
        Clear(JObject);
        foreach PropertyInfo in X509Certificate2.GetType().GetProperties() do
            if PropertyInfo.PropertyType().ToString() in ['System.Boolean', 'System.String', 'System.DateTime', 'System.Int32'] then
                JObject.Add(PropertyInfo.Name(), Format(PropertyInfo.GetValue(X509Certificate2), 0, 9));
        JObject.WriteTo(CertPropertyJson);
    end;
}