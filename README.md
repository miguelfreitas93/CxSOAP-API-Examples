# CxSOAP API Examples
Checkmarx SOAP API Examples (8.X versions)

Examples:

- Powershell (PS1):
    - Add Comment to Results - Powershell
    - Change Assignee of Results - Powershell
    - Change Severity of Results - Powershell
    - Change State of Results - Powershell
    - Get Customized Queries - Powershell
    - Get Last Scan Results - Powershell
    - Get List of Inactive Users - Powershell
- Postman Collection (Postman/README.md):
    - Login
    - Get All Teams
    - Get All Users
    - Get User By ID
    - Delete User By ID
    - Add New User - Server Manager
    - Add New User - SP Manager
    - Add New User - SP Manager - 2 Different SPs
    - Add New User - Company Manager
    - Add New User - Company Manager - 2 Different Companies
    - Add New User - Scanner
    - Add New User - Scanner - 2 Different Teams
    - Add New User - Scanner Delete
    - Add New User - Scanner Delete - 2 Different Teams
    - Add New User - Scanner NE
    - Add New User - Scanner NE - 2 Different Teams
    - Add New User - Scanner NE Delete
    - Add New User - Scanner NE Delete - 2 Different Teams
    - Add New User - Reviewer
    - Add New User - Reviewer - 2 Different Teams
    - Add New User - Reviewer Severity
    - Add New User - Reviewer Severity - 2 Different Teams
    - Update User

In order to build these scripts I had some help from the following endpoints available in 8.X Checkmarx Manager (replace "localhost" with your FQDN):

- Portal (MAIN):	http://localhost/CxWebInterface/Portal/CxWebService.asmx
- SDK:	http://localhost/CxWebInterface/SDK/CxSDKWebService.asmx
- Audit:	http://localhost/CxWebInterface/Audit/CxAuditWebService.asmx
- CLI V1:	http://localhost/CxWebInterface/CLI/CxCLIWebServiceV1.asmx
- CLI V0:	http://localhost/CxWebInterface/CLI/CxCLIWebService.asmx
- IntelliJ:	http://localhost/CxWebInterface/IntelliJ/CxIntelliJWebService.asmx
- Eclipse:	http://localhost/CxWebInterface/Eclipse/CxEclipseWebService.asmx
- Jenkins:	http://localhost/CxWebInterface/Jenkins/CxJenkinsWebService.asmx
- Priority:	http://localhost/CxWebInterface/Priority/CxPriorityService.asmx
- Sonar:	http://localhost/CxWebInterface/Sonar/CxSonarWebService.asmx
- VS:	http://localhost/CxWebInterface/VS/CxVSWebService.asmx

<strong>Note</strong>: Don't forget to have a look over the WSDL to see what is the expected format and structure. If you wanna convert automatically all of the SOAP calls to Postman format, please have a look over my other project called "wsdl2postman": https://github.com/miguelfreitas93/wsdl2postman

# License

MIT License

Copyright (c) 2020 Miguel Freitas
