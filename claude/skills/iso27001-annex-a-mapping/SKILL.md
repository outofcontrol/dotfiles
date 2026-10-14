---
name: iso27001-annex-a-mapping
description: Map technical security findings, misconfigurations, audit observations, or control gaps to ISO/IEC 27001:2022 Annex A controls and clauses 4-10. Use this skill whenever the user is producing a security audit report, compliance report, ISMS document, risk register, statement of applicability, or any output that needs to reference ISO 27001 controls. Also use when the user asks "which control does this map to", mentions Annex A, clauses 4-10, ISMS, statement of applicability, control objective, or wants to phrase a technical finding in audit-appropriate language. Apply even when the user does not explicitly say "ISO 27001" but is writing a security report, compliance deliverable, or audit observation that would benefit from control mapping.
---

# ISO/IEC 27001:2022 Annex A and Clauses Mapping

This skill helps map technical security findings to ISO/IEC 27001:2022 Annex A controls and the main ISMS clauses (4-10). It is for general-purpose use across any security audit, compliance report, risk assessment, or ISMS deliverable.

## When to use this skill

Apply when producing or reviewing:

- Security audit reports that need control references
- Statements of Applicability (SoA)
- Risk registers and risk treatment plans
- ISMS policies, procedures, and management review documents
- Internal or external audit findings, nonconformities, observations
- Remediation plans where each item should cite the control it satisfies
- Vendor security assessments

Also apply when the user asks any variant of:

- "Which Annex A control does X map to?"
- "What ISO 27001 reference should this finding cite?"
- "How do I phrase this finding for an auditor?"
- "What's the control objective for X?"

## Core principles

**A finding usually maps to multiple controls.** Pick the primary control and one or two secondary controls. Resist the urge to list every theoretically related control; that dilutes the report.

**Annex A controls are the "what". Clauses 4-10 are the "how the ISMS itself runs".** Technical findings almost always map to Annex A. A finding about the audit programme, management review, risk methodology, or ISMS scope maps to clauses 4-10 instead.

**Map to the most specific applicable control.** A.5.15 (Access control) is the policy-level umbrella. A.8.2 (Privileged access rights) is more specific. If both apply, cite the specific one as primary and the umbrella as secondary.

**Match the language of the standard.** Auditors expect findings phrased in the standard's terminology: "access rights", "authentication information", "privileged access", "secure development lifecycle", "configuration management", "change management". Translate technical jargon into this vocabulary in the report.

**State the control objective, not just the control number.** "A.8.2" alone is opaque. "A.8.2 Privileged access rights: restrict and manage the allocation and use of privileged access rights" is meaningful in a report.

## How to map a finding

Work through these steps in order:

1. **Identify the asset or process at risk.** Is it information, authentication credentials, access rights, source code, configuration, a network service, a supplier relationship, a development activity?
2. **Identify the control objective the finding undermines.** What was supposed to happen that didn't? Examples: "access should be restricted to authorized users", "authentication information should be protected", "changes should be reviewed".
3. **Match the objective to the Annex A theme.** Annex A:2022 has four themes:
   - **A.5 Organizational controls** (37 controls)
   - **A.6 People controls** (8 controls)
   - **A.7 Physical controls** (14 controls)
   - **A.8 Technological controls** (34 controls)
4. **Find the specific control in that theme.** Use `references/annex-a-controls.md` for the full catalogue with titles and brief descriptions.
5. **If the finding is about ISMS process itself** (audit programme, risk methodology, management review, document control), consult `references/isms-clauses.md` for clauses 4-10.
6. **Cite primary + 1-2 secondary controls.** Format: `A.8.2 (primary), A.5.15, A.5.18 (secondary)`.

## Mapping themes at a glance

Use this lookup to narrow quickly to the right theme before consulting the full catalogue.

| Finding involves | Likely theme | Common controls |
|---|---|---|
| Who can access what, role-based access, permissions | A.5 + A.8 | A.5.15, A.5.18, A.8.2, A.8.3 |
| Passwords, MFA, SSO, identity | A.5 + A.8 | A.5.16, A.5.17, A.8.5 |
| Logging, monitoring, audit logs, SIEM | A.8 | A.8.15, A.8.16, A.8.17 |
| Cryptography, certificates, TLS, signing | A.8 | A.8.24 |
| Software development, code review, SDLC, testing | A.8 | A.8.25, A.8.27, A.8.28, A.8.29, A.8.30, A.8.31, A.8.32 |
| Vulnerabilities, patching, dependency updates | A.8 | A.8.8 |
| Configuration, hardening, baselines | A.8 | A.8.9 |
| Network controls, segmentation, firewalls | A.8 | A.8.20, A.8.21, A.8.22, A.8.23 |
| Backup, recovery, business continuity | A.5 + A.8 | A.5.29, A.5.30, A.8.13, A.8.14 |
| Suppliers, third-party services, cloud providers | A.5 | A.5.19, A.5.20, A.5.21, A.5.22, A.5.23 |
| Incident management, security events | A.5 | A.5.24, A.5.25, A.5.26, A.5.27, A.5.28 |
| Asset management, classification, labelling | A.5 | A.5.9, A.5.10, A.5.11, A.5.12, A.5.13 |
| Physical security, premises, equipment | A.7 | A.7.1 through A.7.14 |
| HR, screening, training, terms of employment | A.6 | A.6.1 through A.6.8 |
| Information transfer, data sharing | A.5 + A.8 | A.5.14, A.8.10, A.8.11, A.8.12 |
| Policies, governance, roles, responsibilities | A.5 | A.5.1, A.5.2, A.5.3, A.5.4 |
| ISMS scope, risk methodology, audit programme, management review | Clauses 4-10 | See `references/isms-clauses.md` |

## Output format

When producing a control-mapped finding, use this structure:

```
Finding: <plain description of what was observed>
Risk: <what could go wrong because of this>
ISO 27001:2022 reference:
  Primary: A.X.Y <Control title>
  Secondary: A.X.Y, A.X.Y
Control objective: <one sentence drawn from the standard's intent>
Recommendation: <specific corrective action>
```

For findings that map to clauses 4-10 instead of Annex A, replace the reference block with:

```
ISO 27001:2022 reference:
  Clause X.Y <Clause title>
```

## Worked examples

See `references/mapping-patterns.md` for fully worked examples across common finding types: GitHub misconfigurations, cloud IAM issues, missing logging, supplier risk, missing policy, etc.

## What this skill does not do

This skill does not perform an audit, generate a Statement of Applicability from scratch, or assess control effectiveness. It maps already-identified findings to the right control references and helps phrase them in audit-appropriate language. For audit programme design and execution methodology, use a dedicated ISMS audit skill (such as `isms-audit-expert`).
