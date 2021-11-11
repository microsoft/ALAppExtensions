#if not CLEAN19
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 132601 "Signature Key Test"
{
    Subtype = Test;

    var
        SignatureKey: Record "Signature Key" temporary;
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure VerifySignatureKeyIsInitialized()
    var
        CertBase64Value: Text;
    begin
        // [SCENARIO] Test initialization of Signature Key record from Base64 value

        // [GIVEN] Test Certificate in the Base64 format
        CertBase64Value := GetCertificateBase64();

        // [THEN] Verify that no error is thrown when the record is being initialized
        SignatureKey.FromBase64String(CertBase64Value, 'Test', true);
    end;

    [Test]
    procedure VerifySignatureKeyIsNotInitialized()
    var
        CertBase64Value: Text;
    begin
        // [SCENARIO] Try initialize Signature Key record from invalid Base64 value

        // [GIVEN] Invalid Test Certificate Base64
        CertBase64Value := GetNotValidBase64Certificate();

        // [WHEN] Initialize record from Base64 value 
        asserterror SignatureKey.FromBase64String(CertBase64Value, 'Test', true);

        // [THEN] Verify that record has not been initialized
        LibraryAssert.ExpectedError('Unable to initialize certificate!');
    end;

    local procedure GetCertificateBase64(): Text
    begin
        exit(
            'MIIKXgIBAzCCChoGCSqGSIb3DQEHAaCCCgsEggoHMIIKAzCCBhwGCSqGSIb3DQEH' +
            'AaCCBg0EggYJMIIGBTCCBgEGCyqGSIb3DQEMCgECoIIE/jCCBPowHAYKKoZIhvcN' +
            'AQwBAzAOBAimW4Quy/otIwICB9AEggTYA/WsXf8pJd+ZERKJaGzrpCck7ORlPZsM' +
            'T21cJyhAQhN57M5Nhu5jfqOJBrHg/AVB42BngTF0AHunvzUWKvRr+iub43JODpr6' +
            'pyYgCM2Z7TfdxOVpDf4G+WJybt7tIHEatFvy9BoAtYig8EZxgfrmNxW0iyd8QhKf' +
            'ifu/GHrxHELQWk1qrmNja44M30pTPxjZrGbfVBGNWc4KEFbCrKTskL2T8THqfFqh' +
            'rL7KrojRbf9vHkDd6J0tVzZnuhvaP/qqu5IuV/kMUGY8gMLvb4dqdGdg8DOtited' +
            'fiwMY2wUJ6QjfWq4fP+/lPlA4SEmmUCJ+tjtQd81mSsko/BMXloQ8np49CCm/p6/' +
            'sft+rtw52B0TNHVqOdqIuVQQCSjAJor2rcj7SN9MprON0SBAUMs/y/1dcmtaVhmU' +
            '2d4Y063dpKWAcm5i6DIEnLKobZonwZVyQtpj3S5vF6dgffhDNlLdIzvR4Cz9933N' +
            'yQ8tLaqj9biLeM4lCnca2qBrdlRy6aZ79Et7nvT3naCnEz8mzzVPc34b1lnlTnWJ' +
            'b35l2Kbsz8Nffo1XbNY+KrnMxUSgSp5nIxzrU1j1g3ojOE2n2ovVCBrusu1g6YxX' +
            '7gdK9pcoDKDadp6x2AOHdSWeGKWmQxjmdW9BMj/XSKie9Dl2Sy6VIv/gULo23NLd' +
            'HzJaudEtdCbDCN1jojbgbfaIpf9636Lh6NfOLzIJRVmXx8l/f789GuSU9CZ3kkI/' +
            'YducHafW+vzCeLAg/WUXgvT5335+N/HQaAfsP43xeDHp2DFi86u+sNM8747SrMim' +
            'y1g70FXBojZx2GUaqVHJfCMU7mUDuwp/zb2cBer0Uq1deBI0KpocHECCAuvQiIkz' +
            'ijT4DMxK4uQJiiS9vRx5ZmXAzyGiHnVey6bE9x1oQFrp5FxD8S5v7imVNywcz6UZ' +
            'JCb0vdvo9SOnrDkKyjCBIwXVNwZUgFRhsbd3mrVbQdqh5r70Eq1Ebg+P8IgxsR/R' +
            '6CJVObNk0/Qm+EOc8s09oIEhl5THzOmK4/XvPuEXgNzdGCEXEj4pRD4zepAN60AN' +
            'Lh2It99HVSW4aEE30S272s9Us/R0h+Bv541iENTq61fmfd0tFAldwlHNppUK3ZJv' +
            'M0sw0XFZ0KA30c6o3UFzmWyukmQ36L+CrEpgiMvUML4/Y1+bLco5Lpcs7vR/w1Mg' +
            'eVaAvS0Zban47jpgq/Jf20iP/yN0f5OX4zprSlZVNBDnx48P+aGk+vt6IGnHYzOf' +
            'abHdnUdlxX1p1qQGWmqfF3Gb1Fe3gmkO3B5s0hBymWiHEUDBMp/w1Vk1L7f7Y5LB' +
            'pOrdjGR9TUUjQx0TpMrpeJg+xoI+BSyU9udSJbU3+py9tOwhxw8W+BM21YyCWbe4' +
            '0nMaRwq7iwyW4vUA6Nqg+F6wVi1vQAQKXk/k4UtoReEbGWLSK8MOPrCJo4IjHpPY' +
            '40yFgYVVMpEGcwGzisDUlg9iizL9Q56aDxpslZ0rs0khZ4KMTMJj4BN3nYVHathd' +
            'PpLCMKjJWPH1Irg5E39QUfEFU+sdq+xcMelsdJ4TsTQsz6jUqssUA6tZY0nJM/N5' +
            'I+jGk8P80gBVJ9nilCXOmJYJJa1MZIpNqisFmWb32AhByHCeCBH1fzIG+ccmypas' +
            'e9lcT/6GzTlngu1CGeeiEDGB7zATBgkqhkiG9w0BCRUxBgQEAQAAADBdBgkqhkiG' +
            '9w0BCRQxUB5OAHQAZQAtADUAYwA4AGQAMQBlADQANgAtADYAYgA1AGUALQA0ADIA' +
            'NAA5AC0AYgA2ADMAOQAtADMANwBjADkANgBhAGQANgA1ADAAMAAyMHkGCSsGAQQB' +
            'gjcRATFsHmoATQBpAGMAcgBvAHMAbwBmAHQAIABFAG4AaABhAG4AYwBlAGQAIABS' +
            'AFMAQQAgAGEAbgBkACAAQQBFAFMAIABDAHIAeQBwAHQAbwBnAHIAYQBwAGgAaQBj' +
            'ACAAUAByAG8AdgBpAGQAZQByMIID3wYJKoZIhvcNAQcGoIID0DCCA8wCAQAwggPF' +
            'BgkqhkiG9w0BBwEwHAYKKoZIhvcNAQwBAzAOBAjTmaMWCz3Y7wICB9CAggOYGc05' +
            '/gVzAS5Joc6zGUlJNNxES94QcrZkrcR9b0wAv3d9+S89IzUjv1vhTsKoKwOnCeEY' +
            '9QoK9ipK0LFuypwAnFKQRV9eGwp1iet69xXbdienM9OodeBKBk3mqzQ9vxQABs1j' +
            'awlGr9hqVtWi6U7MSA75dieJjz5BdAEhkVVqTRBPMRC9tLdivKEbW1ZzNvjRD7xc' +
            'IyxA4lwBR/e6Q3D7/eJWayO3BAyRRssdniRSpTRMWzpwoefCnviV3Ncy7atncvHV' +
            'KGQDOFQBLCgJqPxehJkovabbJCWytpWIZbz3KyoJ3QlXZ2pM05qSX9LayU6py6cH' +
            '1V04h+323J3WTsXvOcLkyU6UagYtRCd9aB01/TruCowVGLr1HtTjFBRXCUdkjQXz' +
            'xTKtJBLOWhpyqrXZxNswj64cLwTjxKokWO1/I1IqWxTF+FQIBbaQhQMz7lxv7BCa' +
            'Mw0T9GrNEhtH3KmhT1E3S8bX7Dyfcwcovxs/r9XOYziZr3Kh9EWCWsIBceDj5m27' +
            'en2lhu/ZnSvlWhRve2Jz7w1OaaFRGld0+KytxpbR8U5U1o3jtKmm71hNXdPq3nke' +
            'W4/tIOTismughMMCORB9hKdhXbQfoOX5vohvqfa3RYIoSy/+qGoQAsolP/UkCsPv' +
            'qOVSHGRj5WfhCmGxq8y9qngCx6pK+Jalvh0rG6k/Wjtt0tsuGChSCJWxU8L0u198' +
            'fEdaUNVlVbKgL9EpRWNcX+B/MMhZ3ydqvLK/5DUXHLuhjDbjwGCyh/vVyU+VyWn1' +
            'QJG2/U2nQDFdl1M0oxFErUIl4188kY9FEWEJSCHoDEsGMG3pFt4FBqcQxrFYbCej' +
            'BI08g9s+y4LNsSgdimJ1UpTj7DCX3i2evrzR6LmEqEarScgAolLGpANRBWX6HvYc' +
            'xt8457T5H2VZLMqlFp9BP0oyN9vfsENppJc89sTAZgqjxzKfjUpjBPF95SoB2Gsp' +
            'u0BILqZuIzmqWourooCpJerz3Ma9oaBxwy5w7/TbjPhN0e1MGP9EIBsDX7zZjE45' +
            '2nlFNTUlmCyFQWUkbdingDrVHf5uXO2f/4VwmCUDBHwqZSic6WbnM7oqhDRwc1wA' +
            'fm0EPp1n6uv1wmF2xgx17HKD9IHv/nm5FHZN2w7dEfC6jsl/QNxs9Gf6gXt4MG57' +
            '2uxLxBrH7IGUqe1w1pGQdxEI0aaacA7c/kV2/ZtSKbWM0XHG2jJGyfXFm5Ong7fw' +
            '1Qr9DL0wOzAfMAcGBSsOAwIaBBQsMLe2jffguWItspxACS3wvjyiBQQUVLMF3wsZ' +
            'cOv5bfFf0GBr0qXfYLcCAgfQ');
    end;

    local procedure GetNotValidBase64Certificate(): Text
    begin
        exit('svZ2agE126JHsQ0bhzN5TKsYfbwfTwfjdWAGy6Vf1nYi/rO+ryMO');
    end;

}
#endif