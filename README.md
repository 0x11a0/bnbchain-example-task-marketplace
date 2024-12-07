### **README: Decentralized Task Marketplace**

# **Decentralized Task Marketplace**
A blockchain-powered platform where users can:
- **Post tasks** with rewards in BNB.
- **Accept tasks** and mark them as completed.
- **Escrow payments** using smart contracts to ensure trust.
- **Store task details** and attachments on BNB Greenfield for decentralized storage.

---

## **Features**
1. Decentralized task creation, assignment, and payment.
2. Smart contract escrow for secure payments.
3. BNB Greenfield integration for task metadata and attachments.
4. A simple web-based frontend using HTML, CSS, and Web3.js for seamless interaction.

---

## **Tech Stack**
- **Blockchain**: BSC Testnet
- **Smart Contracts**: Solidity
- **Storage**: BNB Greenfield
- **Frontend**: HTML, CSS, JavaScript, Web3.js

---

## **Getting Started**

### **1. Prerequisites**
- Node.js and npm installed.
- MetaMask browser extension installed.
- Access to the BSC Testnet and a funded test wallet.
    - 
- Greenfield CLI/SDK configured for uploading files.

### **2. Project Setup**
1. **Clone the Repository**
   ```bash
   git clone https://github.com/0x11a0/bnbchain-example-task-marketplace.git
   cd bnbchain-example-task-marketplace
   ```

2. **Install Dependencies**
   ```bash
   cd app
   npm install
   ```

3. **Smart Contract Deployment**
   - Copy codes from `TaskMarketplace.sol` into Remix IDE.
   - Connect Remix to MetaMask (BSC Testnet).
   - Compile and deploy the smart contract.
   - Save the deployed contract address.

4. **Greenfield Configuration**
   - Use the Greenfield CLI or SDK to upload task metadata.
   - Save the URI of the uploaded file for referencing in the smart contract.

---

### **3. Project Structure**
```
.
├── LICENSE
├── README.md
├── contract
│   └── TaskMarketplace.sol
└── dapp
    ├── index.html
    ├── package.json
    ├── public
    │   └── vite.svg
    └── src
        ├── counter.js
        ├── detect.js
        ├── javascript.svg
        ├── main.js
        └── style.css
```

---

## **Development Guide**

### **Step 1: Smart Contract**
1. Open `TaskMarketplace.sol` in Remix IDE and deploy it to the BSC Testnet.
2. Add your contract address and ABI to `script.js`.

**Example Solidity Contract:**
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TaskMarketplace {
    struct Task {
        address poster;
        address worker;
        uint256 reward;
        bool completed;
        bool paid;
        string dataUri;
    }

    mapping(string => Task) public tasks;

    function createTask(string memory taskId, string memory dataUri, uint256 reward) external payable {
        require(msg.value == reward, "Insufficient payment for reward");
        require(tasks[taskId].reward == 0, "Task already exists");

        tasks[taskId] = Task({
            poster: msg.sender,
            worker: address(0),
            reward: reward,
            completed: false,
            paid: false,
            dataUri: dataUri
        });
    }

    function acceptTask(string memory taskId) external {
        Task storage task = tasks[taskId];
        require(task.reward > 0, "Task does not exist");
        require(task.worker == address(0), "Task already accepted");

        task.worker = msg.sender;
    }

    function markComplete(string memory taskId) external {
        Task storage task = tasks[taskId];
        require(task.worker == msg.sender, "Only the assigned worker can mark complete");
        require(!task.completed, "Task already completed");

        task.completed = true;
    }

    function releasePayment(string memory taskId) external {
        Task storage task = tasks[taskId];
        require(task.poster == msg.sender, "Only the task poster can release payment");
        require(task.completed, "Task is not marked complete");
        require(!task.paid, "Payment already released");

        task.paid = true;
        payable(task.worker).transfer(task.reward);
    }
}
```

---

### **Step 2: Frontend**

#### **1. Set Up the Project**
##### Create a New Vite Project
```bash
npm create vite@latest simple-dapp -- --template vanilla
```

##### Navigate to the Project Directory
```bash
cd simple-dapp
```

##### Install Dependencies
Install the dependencies listed in the `package.json` file:
```bash
npm install
```

---

#### **2. Create the Dapp Structure**
##### Create the Entry JavaScript File
```bash
touch main.js
```

##### Add Basic HTML Structure
Update `index.html`:
```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Simple dapp</title>
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="/main.js"></script>
  </body>
</html>
```

##### Add Content to `main.js`
```javascript
import "./style.css";

document.querySelector("#app").innerHTML = `
  <button class="enableEthereumButton">Enable Ethereum</button>
  <h2>Account: <span class="showAccount"></span></h2>`;
```

---

#### **3. Detect MetaMask**
##### Install the MetaMask Detection Library
```bash
npm install @metamask/detect-provider
```

##### Set Up the Detection Script
Create a `src` directory and `detect.js`:
```bash
mkdir src && touch src/detect.js
```

##### Detect the MetaMask Provider
Add the following to `detect.js`:

```javascript
import detectEthereumProvider from "@metamask/detect-provider";

// Detect and initialize the provider
async function setup() {
  const provider = await detectEthereumProvider();

  if (provider && provider === window.ethereum) {
    console.log("MetaMask is available!");
    startApp(provider);
  } else {
    console.log("Please install MetaMask!");
  }
}

// Initialize the app with the detected provider
function startApp(provider) {
  if (provider !== window.ethereum) {
    console.error("Do you have multiple wallets installed?");
  }
}

window.addEventListener("load", setup);
```

---

#### **4. Detect a User's Network**
##### Add Code to Handle Network Detection
Extend `detect.js` to include network detection:

```javascript
// Detect the user's chain ID
const chainId = await window.ethereum.request({ method: "eth_chainId" });

// Handle network changes
window.ethereum.on("chainChanged", handleChainChanged);

function handleChainChanged(chainId) {
  // Reload the page on network changes
  window.location.reload();
}
```

---

#### **5. Access a User's Accounts**
##### Add Account Request Functionality
Add the following to `detect.js`:

```javascript
// Button and display elements
const ethereumButton = document.querySelector(".enableEthereumButton");
const showAccount = document.querySelector(".showAccount");

// Handle user interaction to request account access
ethereumButton.addEventListener("click", () => {
  getAccount();
});

async function getAccount() {
  const accounts = await window.ethereum
    .request({ method: "eth_requestAccounts" })
    .catch((err) => {
      if (err.code === 4001) {
        console.log("User rejected the request.");
      } else {
        console.error(err);
      }
    });

  if (accounts) {
    const account = accounts[0];
    showAccount.innerHTML = account;
    console.log("Connected account:", account);
  }
}
```

##### Update `index.html`
Add the connection button and account display:
```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Simple dapp</title>
    <script type="module" src="/main.js"></script>
    <script type="module" src="src/detect.js"></script>
  </head>
  <body>
    <!-- Display the connect button and account information -->
    <button class="enableEthereumButton">Enable Ethereum</button>
    <h2>Account: <span class="showAccount"></span></h2>
  </body>
</html>
```

---

#### **6. Task Marketplace Functions**
Add task management functionality to `detect.js`:

##### Create a Task
```javascript
async function createTask(taskId, dataUri, reward) {
  const accounts = await web3.eth.getAccounts();
  try {
    await contract.methods
      .createTask(taskId, dataUri, web3.utils.toWei(reward, "ether"))
      .send({
        from: accounts[0],
        value: web3.utils.toWei(reward, "ether"),
      });
    console.log(`Task ${taskId} created successfully.`);
  } catch (error) {
    console.error("Error creating task:", error);
  }
}
```

##### Accept a Task
```javascript
async function acceptTask(taskId) {
  const accounts = await web3.eth.getAccounts();
  try {
    await contract.methods.acceptTask(taskId).send({ from: accounts[0] });
    console.log(`Task ${taskId} accepted successfully.`);
  } catch (error) {
    console.error("Error accepting task:", error);
  }
}
```

---

#### **7. Run the Project**
Start the development server:
```bash
npm run dev
```

Navigate to the local server URL (e.g., `http://localhost:5173`) to interact with your dApp.

---

## **Contributing**
Pull requests are welcome. For significant changes, please open an issue first to discuss your proposal.

---

## **License**
This project is licensed under the MIT License.