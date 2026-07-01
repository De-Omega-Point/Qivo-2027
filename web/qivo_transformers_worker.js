let classifierPromise = null;

const labels = [
  "calm conversation",
  "rushed urgent conversation",
  "unclear confusing conversation",
  "tense disagreement",
  "emotionally loaded conversation",
];

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

function pressureFromLabel(label) {
  if (label.includes("rushed")) return "fast";
  if (label.includes("unclear")) return "unclear";
  if (label.includes("tense")) return "tense";
  if (label.includes("emotionally")) return "emotionallyLoaded";
  return "calm";
}

async function classifier() {
  if (classifierPromise) return classifierPromise;

  classifierPromise = import(
    "https://cdn.jsdelivr.net/npm/@huggingface/transformers@3.0.0"
  ).then(({ pipeline, env }) => {
    env.allowLocalModels = false;
    return pipeline(
      "zero-shot-classification",
      "Xenova/mobilebert-uncased-mnli",
      { dtype: "q8" }
    );
  });

  return classifierPromise;
}

self.onmessage = async (event) => {
  const { id, type, text } = event.data || {};
  if (type !== "analyze") return;

  try {
    const model = await classifier();
    const output = await model(text, labels);
    const label = Array.isArray(output.labels) ? output.labels[0] : "";
    const fallback = heuristicAnalyze(text);
    self.postMessage({
      id,
      result: {
        pressure: pressureFromLabel(label),
        intent: fallback.intent,
        source: "transformers",
        model: "Xenova/mobilebert-uncased-mnli",
      },
    });
  } catch (error) {
    self.postMessage({
      id,
      result: heuristicAnalyze(text),
    });
  }
};
