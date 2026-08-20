const formatId = (prefix, n) => {
  return `${prefix}_${n.toString().padStart(3, "0")}`;
};

export default formatId;
