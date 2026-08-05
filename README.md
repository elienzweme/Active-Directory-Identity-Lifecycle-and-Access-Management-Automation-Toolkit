# Enterprise IAM Engineering Lab

---

![Platform](https://img.shields.io/badge/Platform-VMware-607078?style=flat-square&logo=vmware&logoColor=white)
![Directory](https://img.shields.io/badge/Directory-Active%20Directory-D9773B?style=flat-square&logo=microsoft&logoColor=white)
![Server](https://img.shields.io/badge/Server-Windows%20Server%202025-0078D4?style=flat-square&logo=windows&logoColor=white)
![Clients](https://img.shields.io/badge/Clients-Windows%2011-00A4EF?style=flat-square&logo=windows11&logoColor=white)
![Automation](https://img.shields.io/badge/Automation-PowerShell-2671BE?style=flat-square&logo=powershell&logoColor=white)
![IAM](https://img.shields.io/badge/IAM-JML%20Automation-6F42C1?style=flat-square)

![Access](https://img.shields.io/badge/Access-RBAC-8A2BE2?style=flat-square)
![HRIS](https://img.shields.io/badge/HRIS-OrangeHRM-F58220?style=flat-square)
![SIEM](https://img.shields.io/badge/SIEM-Splunk-000000?style=flat-square&logo=splunk&logoColor=white)
![Ticketing](https://img.shields.io/badge/Ticketing-Jira-0052CC?style=flat-square&logo=jira&logoColor=white)
![Version](https://img.shields.io/badge/Version-v1.0-1F6FEB?style=flat-square)
![Project](https://img.shields.io/badge/Project-Completed-22A800?style=flat-square)

# Enterprise IAM Engineering Lab v1.0

## Overview

The Enterprise IAM Engineering Lab v1.0 is a hands-on Identity and Access Management (IAM) project designed to simulate the core identity lifecycle processes used in enterprise environments.

This project demonstrates how organizations provision, manage, secure, and audit user identities using Microsoft Active Directory, PowerShell automation, Role-Based Access Control (RBAC), Group Policy, secure file server permissions, OrangeHRM, and Splunk Enterprise.

The lab focuses on implementing a complete Joiner, Mover, and Leaver (JML) lifecycle while enforcing standardized security policies, centralized auditing, and enterprise access management.

---

# Project Objectives

- Design an enterprise Active Directory environment
- Implement Role-Based Access Control (RBAC)
- Automate the Joiner, Mover, and Leaver lifecycle
- Secure departmental resources using Active Directory security groups
- Implement enterprise Group Policy security baselines
- Integrate OrangeHRM as the Human Resources Information System (HRIS)
- Centralize auditing using Splunk Enterprise
- Generate operational reports and validation logs
- Build a scalable foundation for future hybrid identity and governance

---

# Technologies Used

### Identity Services

- Windows Server 2025
- Active Directory Domain Services
- DNS
- Group Policy

### Automation

- PowerShell
- CSV-based JML processing

### Security

- Role-Based Access Control (RBAC)
- Windows LAPS
- Microsoft Defender
- Windows Firewall
- Advanced Audit Policies
- PowerShell Logging

### File Services

- SMB File Shares
- NTFS Permissions
- Access-Based Enumeration (ABE)

### Monitoring

- Splunk Enterprise
- Splunk Universal Forwarder
- Sysmon

### HR System

- OrangeHRM

### Virtualization

- VMware Workstation Pro

---

# Lab Architecture

```
                        OrangeHRM
                           │
                     Employee Records
                           │
                           ▼
                  CSV Lifecycle Requests
                           │
                           ▼
                PowerShell IAM Toolkit
                           │
          ┌────────────────┼────────────────┐
          ▼                ▼                ▼
   Active Directory      FILE01         Splunk Enterprise
      Windows            File Server      Monitoring
          │                │                │
          ▼                ▼                ▼
      RBAC Groups      NTFS ACLs       Security Dashboards
          │
          ▼
     Windows Clients
```

---

# Infrastructure

| Server | Purpose |
|----------|------------------------------|
| DC01 | Active Directory Domain Controller |
| FILE01 | Department File Server |
| SPLUNK01 | Splunk Enterprise SIEM |
| HR01 | OrangeHRM HRIS |
| CLIENT01 | Windows 11 Enterprise |
| CLIENT02 | Windows 11 Enterprise |

Domain:

```
corp.local
```

---

# Active Directory Design

Organizational Units include:

- Accounting
- Customer Relations
- Engineering
- Executives
- Finance
- HR
- IT
- Security
- Workstations
- Servers
- Contractors
- Disabled Users
- Privileged Accounts

---

# Role-Based Access Control (RBAC)

Department-based security groups are used to manage authorization.

Examples include:

| Department | Security Group |
|------------|----------------|
| Accounting | GG-Accounting-Users |
| HR | GG-HR-Users |
| Finance | GG-Finance-Users |
| Engineering | GG-Engineering-Users |
| IT | GG-IT-Users |
| Security | GG-Security-Users |

Permissions are assigned through group membership rather than directly to users.

---

# Identity Lifecycle Automation

The PowerShell IAM Toolkit automates:

## Joiner

- User creation
- Identity attributes
- Department assignment
- Group membership
- Home directory creation
- Department drive mapping

---

## Mover

- Department changes
- Manager updates
- Title updates
- Security group changes
- File server permission updates

---

## Leaver

- Disable account
- Reset password
- Remove security groups
- Move account to Disabled Users OU
- Preserve home directory
- Generate reports

---

# Group Policy Security Baseline

Implemented policies include:

- Windows LAPS
- Microsoft Defender
- Windows Firewall
- PowerShell Module Logging
- PowerShell Script Block Logging
- Advanced Audit Policies
- Removable Storage Restrictions
- Department Drive Mapping
- Workstation Security Baseline
- File Server Security Policy

---

# File Server

FILE01 hosts:

```
Departments
│
├── Accounting
├── Customer Relations
├── Engineering
├── Executives
├── Finance
├── HR
├── IT
└── Security

HomeFolders
```

Security includes:

- NTFS Permissions
- Access-Based Enumeration
- RBAC Authorization
- Department Shares

---

# OrangeHRM Integration

OrangeHRM serves as the simulated Human Resources Information System.

Current Version:

```
OrangeHRM
        │
        ▼
Employee Records
        │
        ▼
CSV Request
        │
        ▼
PowerShell IAM Toolkit
```

Future versions will integrate directly with the OrangeHRM API.

---

# Splunk Monitoring

The following data sources are collected:

- Active Directory
- Windows Security Logs
- Windows System Logs
- PowerShell Logs
- Sysmon
- File Server Audit Logs

Key monitored Event IDs include:

| Event ID | Description |
|-----------|-------------|
|4624|Successful Logon|
|4625|Failed Logon|
|4720|User Created|
|4724|Password Reset|
|4725|User Disabled|
|4728|Group Membership Added|
|4729|Group Membership Removed|
|4740|Account Lockout|
|4104|PowerShell Script Block|
|4663|File Access|
|5140|Network Share Access|
|5145|Share Authorization|

---

# Testing

The following components have been successfully validated:

- Active Directory
- Organizational Units
- RBAC
- Group Policy
- Windows LAPS
- Microsoft Defender
- Windows Firewall
- Joiner Automation
- Mover Automation
- Leaver Automation
- File Server Permissions
- OrangeHRM
- Splunk Monitoring

---

# Project Highlights

✔ Active Directory Engineering

✔ Identity Lifecycle Automation

✔ Role-Based Access Control

✔ PowerShell Automation

✔ Group Policy Security Baseline

✔ Windows LAPS

✔ Enterprise File Server

✔ OrangeHRM Integration

✔ Splunk Enterprise Monitoring

✔ Centralized Auditing

✔ Automated Reporting

---

# Current Version

## Version 1.0

Implemented:

- Active Directory
- PowerShell IAM Toolkit
- RBAC
- File Server
- OrangeHRM
- Group Policy
- Splunk Enterprise
- Security Baseline
- Reporting

Lifecycle Requests:

```
CSV
→ PowerShell
→ Active Directory
→ File Server
→ Reports
→ Splunk
```

---

# Future Roadmap

## Version 2.0

- Jira Service Management Integration
- Jira REST API
- Ticket-driven Joiner, Mover, Leaver workflows
- Approval-based provisioning
- Automated ticket updates
- Enhanced reporting

Architecture:

```
Jira
     │
     ▼
PowerShell Processor
     │
     ▼
Active Directory
     │
     ▼
Splunk
```

---

## Version 3.0

Hybrid Identity

- Microsoft Entra ID
- Microsoft Entra Connect / Cloud Sync
- Microsoft Graph
- Group-based cloud provisioning
- Conditional Access
- Multi-Factor Authentication (MFA)

---

## Version 4.0

Identity Federation

- Okta Integrator Free Plan
- SAML 2.0
- OpenID Connect (OIDC)
- Application Provisioning
- Access Reviews
- Identity Governance
- Automated Compliance Reporting

---

# Skills Demonstrated

- Active Directory Administration
- Identity & Access Management (IAM)
- Role-Based Access Control (RBAC)
- PowerShell Automation
- Windows Server Administration
- Group Policy Management
- Windows LAPS
- Microsoft Defender
- Windows Firewall
- NTFS Permissions
- SMB File Services
- OrangeHRM Administration
- Splunk Enterprise
- SIEM Monitoring
- Security Auditing
- Identity Lifecycle Management
- Infrastructure Documentation

---

# Author

**Elie Nzweme**

Enterprise IAM Engineering Lab v1.0

Identity & Access Management | Active Directory | PowerShell | Splunk | Windows Server | Cybersecurity
