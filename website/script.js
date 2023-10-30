const displayStatus = (message, type) => {
  const statusBar = document.getElementById("statusBar");
  statusBar.textContent = message;
  statusBar.className = `alert alert-${type}`;
};

const addToRecentSnippets = (id, content) => {
  const snippetList = document.getElementById("recentSnippets");
  const listItem = document.createElement("li");
  listItem.className = "list-group-item list-group-item-action";
  listItem.textContent = "Snippet ID: " + id;
  listItem.addEventListener("click", () => {
    document.getElementById("snippetContent").value = content;
    document.getElementById("snippetID").value = id;
    displayStatus(`Loaded snippet ID: ${id} into the editor.`, "info");
  });
  snippetList.prepend(listItem);
};

const createSnippet = async () => {
  const content = document.getElementById("snippetContent").value;

  try {
    const response = await fetch(
      "https://gkavxhm7fh.execute-api.us-east-1.amazonaws.com/test/snippets",
      {
        mode: "cors",
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ content }),
      },
    );

    const data = await response.json();

    if (data.id) {
      displayStatus(`Snippet created with ID: ${data.id}`, "success");
      addToRecentSnippets(data.id, content);
    } else {
      displayStatus(
        "Probably throttled. Please wait at least 5 seconds.",
        "danger",
      );
    }
  } catch (error) {
    console.error("Error:", error);
  }
};

const getSnippet = async () => {
  const id = document.getElementById("snippetID").value;

  try {
    const response = await fetch(
      `https://gkavxhm7fh.execute-api.us-east-1.amazonaws.com/test/snippets?snippet=${id}`,
      {
        mode: "cors",
      },
    );

    const data = await response.json();

    if (data.content) {
      document.getElementById("retrievedSnippet").textContent = data.content;
    } else {
      displayStatus(
        "Failed to retrieve snippet. Please check the ID, or wait at least 5 seconds in case of throttling.",
        "warning",
      );
    }
  } catch (error) {
    console.error("Error:", error);
  }
};
