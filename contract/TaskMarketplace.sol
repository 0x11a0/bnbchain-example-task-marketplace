// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TaskMarketplace
 * @dev A decentralized marketplace for tasks where users can post tasks, accept them, and manage payments in a trustless manner.
 */
contract TaskMarketplace {
    // Define a structure to represent a task
    struct Task {
        address poster;    // The address of the user who posted the task
        address worker;    // The address of the user who accepted the task
        uint256 reward;    // The reward amount (in Wei) for completing the task
        bool completed;    // A boolean indicating if the task has been marked as completed
        bool paid;         // A boolean indicating if the reward has been paid out
        string dataUri;    // A URI pointing to task metadata (stored off-chain)
    }

    // Mapping to store tasks by their unique string ID
    mapping(string => Task) public tasks;

    /**
     * @notice Creates a new task with a reward
     * @param taskId The unique ID of the task
     * @param dataUri The URI of the task metadata (off-chain storage)
     * @param reward The reward amount for the task
     * @dev The task poster must send `reward` in Wei along with the transaction.
     */
    function createTask(string memory taskId, string memory dataUri, uint256 reward) external payable {
        // Ensure that the value sent matches the reward
        require(msg.value == reward, "Insufficient payment for reward");
        // Ensure the task ID is not already in use
        require(tasks[taskId].reward == 0, "Task already exists");

        // Create a new task and store it in the mapping
        tasks[taskId] = Task({
            poster: msg.sender,     // Set the poster to the sender of the transaction
            worker: address(0),     // Initialize the worker as the zero address
            reward: reward,         // Set the reward for the task
            completed: false,       // Task is not completed initially
            paid: false,            // Task is not paid initially
            dataUri: dataUri        // Store the task's metadata URI
        });
    }

    /**
     * @notice Accepts an available task
     * @param taskId The ID of the task to accept
     * @dev Only tasks that have not already been accepted can be accepted.
     */
    function acceptTask(string memory taskId) external {
        // Retrieve the task from the mapping
        Task storage task = tasks[taskId];
        // Ensure the task exists (reward > 0)
        require(task.reward > 0, "Task does not exist");
        // Ensure the task has not already been accepted
        require(task.worker == address(0), "Task already accepted");

        // Assign the worker to the sender of the transaction
        task.worker = msg.sender;
    }

    /**
     * @notice Marks a task as completed
     * @param taskId The ID of the task to mark as completed
     * @dev Only the assigned worker can mark the task as completed.
     */
    function markComplete(string memory taskId) external {
        // Retrieve the task from the mapping
        Task storage task = tasks[taskId];
        // Ensure the sender is the assigned worker
        require(task.worker == msg.sender, "Only the assigned worker can mark complete");
        // Ensure the task has not already been marked as completed
        require(!task.completed, "Task already completed");

        // Mark the task as completed
        task.completed = true;
    }

    /**
     * @notice Releases the payment to the worker
     * @param taskId The ID of the task for which payment is to be released
     * @dev Only the poster can release payment, and only if the task is marked completed.
     */
    function releasePayment(string memory taskId) external {
        // Retrieve the task from the mapping
        Task storage task = tasks[taskId];
        // Ensure the sender is the poster of the task
        require(task.poster == msg.sender, "Only the task poster can release payment");
        // Ensure the task has been marked as completed
        require(task.completed, "Task is not marked complete");
        // Ensure the payment has not already been released
        require(!task.paid, "Payment already released");

        // Mark the payment as released
        task.paid = true;
        // Transfer the reward to the worker
        payable(task.worker).transfer(task.reward);
    }
}
