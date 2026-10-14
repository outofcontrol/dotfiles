# Mapping Patterns: Worked Examples

Each example shows a raw technical finding, the mapping reasoning, and the final report-ready phrasing. Use these as templates when mapping new findings.

## Example 1: Branch protection missing on default branch

**Raw finding**: The default branch of repo `acme-corp/web-app` has no branch protection rule or ruleset; force pushes and direct commits are allowed without review.

**Reasoning**:
- The asset is source code and the deployment pipeline.
- The objective undermined is "changes must be reviewed before being incorporated".
- Theme is A.8 Technological controls.
- Primary control: A.8.32 Change management (changes to systems must be subject to change management procedures).
- Secondary: A.8.25 Secure development life cycle, A.8.4 Access to source code.

**Report-ready phrasing**:
```
Finding: The default branch in acme-corp/web-app has no branch protection or
ruleset. Direct commits and force pushes are permitted without peer review.
Risk: Untested or malicious changes can reach production without review,
bypassing the secure development life cycle and undermining the integrity of
deployed software.
ISO 27001:2022 reference:
  Primary: A.8.32 Change management
  Secondary: A.8.25 Secure development life cycle, A.8.4 Access to source code
Control objective: Changes to information processing facilities and systems
shall be subject to change management procedures.
Recommendation: Enable a branch protection rule or ruleset on the default
branch requiring at least one approving review, status checks, and prohibition
of force pushes and deletions.
```

## Example 2: Org-wide 2FA not enforced

**Raw finding**: The GitHub organization does not require members to enable two-factor authentication.

**Reasoning**:
- Asset is authentication to the org and the data behind it.
- Objective undermined is "secure authentication".
- Primary: A.8.5 Secure authentication.
- Secondary: A.5.17 Authentication information, A.5.16 Identity management.

**Report-ready phrasing**:
```
Finding: Two-factor authentication is not enforced for members of the GitHub
organization.
Risk: A compromised password alone permits access to the organization's
repositories, secrets, and administrative functions.
ISO 27001:2022 reference:
  Primary: A.8.5 Secure authentication
  Secondary: A.5.17 Authentication information, A.5.16 Identity management
Control objective: Secure authentication technologies and procedures shall be
implemented based on information access restrictions.
Recommendation: Enforce two-factor authentication organization-wide via the
GitHub organization security settings.
```

## Example 3: Webhook without secret

**Raw finding**: An organization webhook posts to an external CI system without a configured secret, so receivers cannot validate the HMAC signature.

**Reasoning**:
- Asset is the information in transit and the receiving system's trust boundary.
- Objectives undermined: information transfer integrity and authentication of source.
- Primary: A.5.14 Information transfer.
- Secondary: A.8.24 Use of cryptography (HMAC is the cryptographic mechanism).

**Report-ready phrasing**:
```
Finding: An organization webhook is configured without a shared secret. The
receiving system cannot verify the HMAC signature of incoming payloads.
Risk: Forged webhook payloads cannot be distinguished from legitimate traffic.
An attacker who learns the receiver URL can inject events.
ISO 27001:2022 reference:
  Primary: A.5.14 Information transfer
  Secondary: A.8.24 Use of cryptography
Control objective: Information transfer rules and procedures shall be in place
to protect information in transit between the organization and other parties.
Recommendation: Configure a strong shared secret on the webhook and verify the
X-Hub-Signature-256 header at the receiver.
```

## Example 4: Secret scanning push protection disabled

**Raw finding**: Push protection for secret scanning is disabled on multiple repositories. Secrets committed to history are detected after the fact rather than blocked at push.

**Reasoning**:
- Asset is credential material.
- Objective: prevent leakage of authentication information.
- Primary: A.5.17 Authentication information.
- Secondary: A.8.28 Secure coding, A.8.12 Data leakage prevention.

**Report-ready phrasing**:
```
Finding: Secret scanning push protection is not enabled on 14 of 47 in-scope
repositories. Detection of committed secrets occurs after the fact rather than
blocking the push.
Risk: Developer-introduced credentials may be present in commit history for a
window of time, increasing exposure if the repository is public or later
declassified.
ISO 27001:2022 reference:
  Primary: A.5.17 Authentication information
  Secondary: A.8.28 Secure coding, A.8.12 Data leakage prevention
Control objective: Allocation and management of authentication information
shall be controlled by a management process.
Recommendation: Enable push protection on the organization or repository level
in Code security settings. Restrict bypass to administrators.
```

## Example 5: GitHub Actions workflow uses unpinned third-party action

**Raw finding**: Workflow `release.yml` references `some-org/release-action@v3` (a moveable tag) rather than a full commit SHA.

**Reasoning**:
- Asset is the build pipeline and anything the action can touch (secrets, repo contents).
- Objective: control the supply chain for build-time dependencies.
- Primary: A.5.19 Information security in supplier relationships.
- Secondary: A.8.30 Outsourced development, A.8.25 Secure development life cycle.

**Report-ready phrasing**:
```
Finding: The release workflow uses third-party GitHub Actions referenced by
moveable version tags rather than pinned commit SHAs.
Risk: A compromised or maliciously updated upstream action would execute in
the build pipeline with access to repository secrets and contents.
ISO 27001:2022 reference:
  Primary: A.5.19 Information security in supplier relationships
  Secondary: A.8.30 Outsourced development, A.8.25 Secure development life cycle
Control objective: Processes and procedures shall be defined and implemented
to manage the information security risks associated with the use of supplier
products or services.
Recommendation: Pin each third-party action to a full commit SHA with a
version comment alongside, e.g., uses: some-org/release-action@<sha> # v3.1.2.
```

## Example 6: Dormant org admin accounts

**Raw finding**: Three organization admins have not logged in or performed actions in over six months.

**Reasoning**:
- Asset is access to administrative functions of the org.
- Objective: access rights kept aligned with current need.
- Primary: A.5.18 Access rights.
- Secondary: A.8.2 Privileged access rights.

**Report-ready phrasing**:
```
Finding: Three users hold organization admin privileges but have shown no
activity for periods exceeding 180 days.
Risk: Dormant privileged accounts increase the blast radius of a credential
compromise without providing operational value.
ISO 27001:2022 reference:
  Primary: A.5.18 Access rights
  Secondary: A.8.2 Privileged access rights
Control objective: Access rights shall be provisioned, reviewed, modified, and
removed in accordance with the access control policy.
Recommendation: Implement a quarterly access review for privileged roles.
Downgrade or remove the identified dormant admin accounts.
```

## Example 7: No logging on a security-relevant service

**Raw finding**: A self-hosted authentication proxy does not forward logs to the central log aggregator.

**Reasoning**:
- Asset is the audit trail of authentication events.
- Primary: A.8.15 Logging.
- Secondary: A.8.16 Monitoring activities.

**Report-ready phrasing**:
```
Finding: The self-hosted authentication proxy does not forward its access logs
to the central logging facility. Logs are retained locally for 14 days only.
Risk: Authentication failures, anomalous access patterns, and post-incident
forensics are constrained by local retention and the absence of aggregation.
ISO 27001:2022 reference:
  Primary: A.8.15 Logging
  Secondary: A.8.16 Monitoring activities
Control objective: Logs that record activities, exceptions, faults, and other
relevant events shall be produced, stored, protected, and analyzed.
Recommendation: Configure the proxy to forward logs to the central aggregator.
Define a retention period aligned with the organization's incident response
and regulatory requirements.
```

## Example 8: ISMS-process finding (clause, not Annex A)

**Raw finding**: The internal audit programme is documented but the last internal audit was performed 18 months ago. The procedure requires annual audits.

**Reasoning**:
- This is about the ISMS itself, not a technical control.
- The internal audit programme falls under clause 9.2.
- Secondary clause: 10.2 if the lapse has been identified previously without corrective action.

**Report-ready phrasing**:
```
Finding: The internal audit procedure mandates annual ISMS internal audits.
The most recent internal audit was conducted 18 months ago.
Risk: Without scheduled internal audits, the organization cannot confirm the
ISMS continues to conform to its planned arrangements and to the requirements
of ISO 27001.
ISO 27001:2022 reference:
  Clause 9.2 Internal audit
  Clause 10.2 Nonconformity and corrective action
Control objective: The organization shall conduct internal audits at planned
intervals to provide information on whether the ISMS conforms to the
organization's own requirements and to the requirements of this standard.
Recommendation: Schedule and complete an internal audit within the next 60
days. Update the audit programme to track schedule adherence as a KPI for the
next management review.
```

## Quick reference: high-frequency primary control picks

| Finding pattern | Primary control |
|---|---|
| MFA not enforced | A.8.5 |
| Password policy weak or absent | A.5.17 |
| Privileged accounts not reviewed | A.5.18 |
| Privileged role assignment loose | A.8.2 |
| Source code access too broad | A.8.4 |
| Logs missing or not aggregated | A.8.15 |
| No SIEM/monitoring | A.8.16 |
| TLS misconfigured | A.8.24 |
| No code review enforcement | A.8.32 |
| Unpinned dependencies/actions | A.5.19 |
| No vulnerability management | A.8.8 |
| Configuration drift | A.8.9 |
| Secrets in code | A.5.17 |
| Webhook without secret | A.5.14 |
| No backup or untested backup | A.8.13 |
| No DR plan | A.5.30 |
| Cloud service not assessed | A.5.23 |
| Supplier security not reviewed | A.5.22 |
| Incident response undocumented | A.5.24 |
| No threat intelligence | A.5.7 |
| Dev/prod not separated | A.8.31 |
| Untrained personnel | A.6.3 |
| Physical access uncontrolled | A.7.2 |
