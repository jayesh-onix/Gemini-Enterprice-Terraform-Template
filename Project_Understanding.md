# 🚀 The Ultimate Beginner's Guide to OANDA's Gemini Enterprise Terraform Project

Welcome to the team! 🎉 If you're new to Terraform and have been tasked with understanding and expanding the **Gemini Enterprise Automation** project, you are in exactly the right place. 

This guide is designed to be your compass. We will demystify Terraform, break down the exact structure of this project, and explain what every single file does in plain, simple English. By the end of this, you'll be ready to confidently dive in and start building!

---

## 🏗️ 1. Terraform 101: What is this "Magic"?

Imagine you want to build a massive, complex Lego castle. 
- The **old way** (Manual) is opening the Google Cloud Console in your browser and clicking a hundred different buttons to create servers, databases, and search engines. It's slow, and if you make a mistake, it's hard to track.
- The **Terraform way** (Infrastructure as Code - IaC) is writing a "Master Instruction Manual" in code. You tell Terraform *what* you want the final castle to look like, and Terraform automatically talks to Google Cloud to build it exactly as specified. 

### The 4 Magic Words in Terraform Code:
When you open the files in this project, you'll see these four keywords everywhere:
1. 🧱 **`resource` (The Builder):** This tells Google Cloud to actually create something new. *(Example: Create a new Gemini Search Engine).*
2. 🔍 **`data` (The Detective):** This tells Terraform to go find information about something that *already exists*. *(Example: Go find the secret Jira password stored in Google Secret Manager).*
3. 🎛️ **`variable` (The Dials):** These are settings or inputs. Instead of hardcoding a name like "Oanda-Search", we use a variable so we can easily change it later.
4. 📦 **`module` (The Blueprint):** A module is just a folder of Terraform code that acts as a reusable template. 

---

## 🗺️ 2. The Big Picture: What Does This Project Do?

This project automatically builds a **Google Gemini Enterprise Search Engine** for OANDA. But a search engine is useless without data! So, this code also builds **Data Connectors**—secure bridges that allow Gemini to read and search through OANDA's Jira tickets, Confluence pages, Google Drive files, and Salesforce data.

---

## 📂 3. File-by-File Tour (The Source Code Anatomy)

The project is split into two main areas: **The Environment** (where we deploy things) and **The Core Module** (our reusable blueprint).

### 🌍 Area A: The Environment (`oanda-dev-agentspace/`)
This folder represents the actual "Dev" environment we are building. It takes the generic blueprint and feeds it specific OANDA settings.

* **`main.tf`**: The Orchestrator. 
  * It configures the "Backend" (a Google Cloud Storage bucket named `oanda-dev-tfstate` where Terraform remembers the current state of the castle).
  * It calls our custom `module "gemini_enterprise"` to build the search engine.
  * It creates secure **Service Accounts** (robot users) like `oanda-dev-agent-sa` (for automation) and `oanda-api-agent` (to talk to the search API).
  * It assigns IAM permissions (who is allowed to use what).
* **`terraform.tfvars`**: The Control Panel. 
  * This is the most important file for day-to-day changes! It holds the *actual values*. Want to turn the Jira connector on or off? Change `enable_jira_connector = false` to `true` here. Want to change how often Confluence syncs? You do it here.
* **`variables.tf`**: The Rulebook. 
  * It lists every possible setting that `terraform.tfvars` is allowed to configure, along with descriptions of what they do.
* **`providers.tf`**: The Translator. 
  * It simply tells Terraform, "Hey, we are going to be talking to Google Cloud (`google`), so load the right tools."
* **`outputs.tf`**: The Receipt. 
  * After Terraform finishes building, this file tells it to print out useful information (like the ID of the new Search Engine) to the console.

### 🧩 Area B: The Core Module (`modules/gemini-enterprise/`)
This is the "Generic Template" you've been assigned to work on. It's the reusable engine that actually does the heavy lifting.

* **`main.tf`**: The Heart of the Search.
  * Creates the `google_discovery_engine_search_engine` (The actual Gemini Search app).
  * Manages the Gemini Enterprise licenses.
  * Configures the **Search Widget** (the UI popup where users type their search queries, complete with OANDA logos and autocomplete settings).
* **The Connector Files (`jira.tf`, `confluence.tf`, `salesforce.tf`, `mail.tf`, `calendar.tf`, `drive.tf`)**: The Bridges.
  * Each file handles one specific tool. For example, `jira.tf` will:
    1. Read the Jira Client ID and Secret securely from Google Secret Manager.
    2. Give the search engine permission to use those secrets.
    3. Create the `google_discovery_engine_data_connector` which tells Gemini to start pulling data from Atlassian.
* **`variables.tf`**: The inputs this specific module expects from the Environment's `main.tf`.
* **`versions.tf`**: Specifies exactly which version of Terraform and the Google Cloud tools are required to prevent compatibility bugs.

---

## 🤖 4. How Changes Get Deployed (Meet Atlantis)

Because this code controls real cloud infrastructure, **we never run `terraform apply` directly from our personal laptops.** It's too risky! 

Instead, we use a CI/CD workflow with a robot helper named **Atlantis** (configured via the `atlantis.yaml` file in the root folder):

1. **Write Code:** You make changes on a new Git branch.
2. **Open a PR:** You open a Pull Request on your code repository.
3. **Atlantis Plans:** Atlantis automatically sees your PR and runs `terraform plan`. It comments on your PR with a detailed list saying, *"If you merge this, I will create 2 new things, modify 1 thing, and destroy 0 things."*
4. **Review & Apply:** Your team reviews the code and the Atlantis plan. Once approved, you type `atlantis apply` in the PR comments. Atlantis builds it in Google Cloud, and you're done!

---

## 🎯 5. Your First Mission: How to Start Working

If your task is to understand this template and eventually add a new connector or tweak an existing one, here is your workflow:

### Scenario: You need to add a brand new connector (e.g., GitHub)
1. **The Blueprint (Module):** Go into `modules/gemini-enterprise/`. Create a new file called `github.tf`. Look at `jira.tf` to see how it's done. You'll need to write code to fetch the GitHub secret passwords and create the data connector resource.
2. **The Rules:** Open `modules/gemini-enterprise/variables.tf` and add new variables like `enable_github_connector`.
3. **The Orchestrator:** Go to `oanda-dev-agentspace/main.tf` where it says `module "gemini_enterprise"`. Pass your new variables into the module block.
4. **The Control Panel:** Finally, open `oanda-dev-agentspace/terraform.tfvars` and add `enable_github_connector = true` and provide the necessary GitHub configuration.

### Advice for Beginners:
* **Read `terraform.tfvars` first:** It reads like plain English and will instantly tell you exactly what is currently turned on and off.
* **Copy/Paste is your friend:** If you need to make a new connector, copy an existing one (like `confluence.tf`), paste it, and carefully rename the resources. 
* **Don't hardcode passwords:** Always rely on Secret Manager (`data "google_secret_manager_secret_version"`) as shown in the existing connector files.

You've got this! Terraform has a slight learning curve, but once it clicks, you'll feel like a cloud architect wizard. Happy coding! 🚀