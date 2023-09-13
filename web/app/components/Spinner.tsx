export function Spinner() {
  return (
    <div className="flex justify-center items-center">
      <svg
        className="animate-spin h-8 w-8"
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 16 16"
      >
        <circle
          className="opacity-25"
          cx="8"
          cy="8"
          r="6"
          stroke="currentColor"
          strokeWidth="2"
        ></circle>
        <path
          className="opacity-75"
          fill="currentColor"
          d="M2 8a6 6 0 016-6V0C3.373 0 0 3.373 0 8h2zm1 3.547A5.986 5.986 0 012 8H0c0 2.285.97 4.378 2.541 5.853l1.459-0.806z"
        ></path>
      </svg>
    </div>
  );
}
