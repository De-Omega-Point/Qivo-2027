(function () {
  const pending = new Map();
  let worker = null;
  let nextId = 1;

  function heuristicAnalyze(text) {
    const lower = String(text || "").toLowerCase();
    const containsAny = (words) => words.some((word) => lower.includes(word));
    let pressure = "calm";

    if (
      containsAny([
        "angry",
        "wrong",
        "unacceptable",
        "blame",
        "fault",
        "never",
        "always",
      ])
    ) {
      pressure = "tense";
    } else if (
      containsAny([
        "upset",
        "hurt",
        "scared",
        "anxious",
        "overwhelmed",
        "sorry",
        "important",
      ])
    ) {
      pressure = "emotionallyLoaded";
    } else if (
      containsAny(["now", "urgent", "quick", "deadline", "immediately", "asap"])
    ) {
      pressure = "fast";
    } else if (
      containsAny(["maybe", "not sure", "confused", "unclear"]) ||
      lower.split("?").length > 2
    ) {
      pressure = "unclear";
    }

    let intent = "support";
    if (lower.includes("?")) intent = "clarify";
    if (lower.includes("decide") || lower.includes("commit")) intent = "decision";
    if (lower.includes("sorry") || lower.includes("upset")) intent = "repair";
    if (lower.includes("deadline") || lower.includes("urgent")) intent = "pace";

    return { pressure, intent, source: "heuristic" };
  }

  function getWorker() {
    if (worker) return worker;

    try {
      worker = new Worker("qivo_transformers_worker.js", { type: "module" });
      worker.onmessage = (event) => {
        const { id, result } = event.data || {};
        const request = pending.get(id);
        if (!request) return;

        window.clearTimeout(request.timeout);
        pending.delete(id);
        request.resolve(result || heuristicAnalyze(request.text));
      };
      worker.onerror = () => {
        for (const [id, request] of pending.entries()) {
          window.clearTimeout(request.timeout);
          pending.delete(id);
          request.resolve(heuristicAnalyze(request.text));
        }
        worker = null;
      };
    } catch (error) {
      worker = null;
    }

    return worker;
  }

  window.QivoTransformers = {
    analyze(text) {
      const cleanText = String(text || "").trim();
      if (!cleanText) return Promise.resolve(heuristicAnalyze(cleanText));

      const activeWorker = getWorker();
      if (!activeWorker) return Promise.resolve(heuristicAnalyze(cleanText));

      return new Promise((resolve) => {
        const id = nextId++;
        const timeout = window.setTimeout(() => {
          pending.delete(id);
          resolve(heuristicAnalyze(cleanText));
        }, 1600);

        pending.set(id, {
          resolve,
          timeout,
          text: cleanText,
        });
        activeWorker.postMessage({
          type: "analyze",
          id,
          text: cleanText,
        });
      });
    },
  };
})();
