# FAST Agents - App & AI Starter Templates

Welcome to FAST (App & AI Starter Templates), a collection of standardized, reusable Copilot Studio agent templates for Microsoft Power Platform, purpose-built for common business processes across industries. Each agent module defines topics, actions, knowledge sources, and integrations that align with real-world operational needs. By adopting these agents, organizations and solution builders can accelerate AI-powered conversational experiences, ensure consistency across deployments, and reduce the cost of custom development. Whether you are building support agents, process automation agents, information retrieval agents, or other conversational AI solutions, these modules provide a ready-to-use foundation that is extensible, interoperable, and maintained under an open MIT license.

## 📁 Repository Structure

Agents will be organized into domain-based categories:

### Example / Potential Agent Categories

- **administrative/** - Executive coordination, member organizations
- **compliance-security/** - Investigations, personnel security
- **external-engagement/** - Event management, external interactions, programs and services
- **financial/** - Financial management and accounting
- **government/** - Civic engagement, court case management, legislative operations, gov-core
- **operations/** - Asset management, facilities, IT service management, operational excellence, project tracking, request tracker
- **shared/** - Core shared components, reusable topics, common actions, integration templates
- **workforce/** - HR administration, benefits, recruiting, training, knowledge management, time tracking, gamification

Each agent module will typically contain:

- Copilot Studio bot definition files
- Topic definitions and conversation flows
- Action configurations and integrations
- Knowledge source references
- BUILD.md documentation
- PowerShell deployment scripts

## 🛠️ Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit [Contributor License Agreements](https://cla.opensource.microsoft.com).

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

We are working on integrating the full unpacked agent files for a more direct contribution experience. Check back for updates for availability.

## ™️ Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.

## 📌 Intended Use

The agents in this repository are provided as **reference implementations** for learning, experimentation, and as a starting point for building production-ready conversational AI solutions.

They are **not** designed to be deployed directly to a production environment without additional development, testing, and validation. Any organization planning to use these agents in production should:

* Adapt and extend the agents to meet specific business and technical requirements
* Integrate them into the organization's **Application Lifecycle Management (ALM)** processes
* Perform full **security, compliance, and performance reviews**
* Test conversational flows thoroughly with representative user scenarios
* Apply updates, fixes, and enhancements as needed

These agents are meant to accelerate solution design and reduce initial build time, but the responsibility for ensuring readiness, compliance, and ongoing maintenance lies with the implementing organization.

## ⚖️ Support 

The agents in this repository are provided **"as is"** without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and non-infringement.

As open source, these solutions are **not** official Microsoft products and are **not** covered by any Microsoft support agreement or service-level commitment. No guarantee is made regarding the accuracy, completeness, performance, or continued availability of these agents.

Use of these agents is at your own risk. You are responsible for evaluating their suitability for your environment, performing necessary security reviews, and ensuring compliance with applicable laws, regulations, and policies.

By installing or using these agents, you acknowledge that no obligation exists for Microsoft or the repository maintainers to provide support, updates, or maintenance, and that any assistance provided is voluntary and without guarantee.

## 🔗 Related Resources

This repository is part of the FAST ecosystem:

- **[industry-apps](https://github.com/microsoft/industry-apps)** - Model-driven apps and Canvas Apps for Power Platform
- **[industry-solutions](https://github.com/microsoft/industry-solutions)** - Documentation site for FAST modules and agents
- **industry-portals** (planned) - Power Pages solutions for external-facing portals
