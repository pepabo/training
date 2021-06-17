import { useState } from "react";

const PetsPage = () => {
  const defaultPets = [
    { name: "Pochi", species: "dog" },
    { name: "Tama", species: "cat" },
    { name: "Mike", species: "cat" },
    { name: "Hachi", species: "dog" },
  ];

  const [pets, setPets] = useState(defaultPets);
  const [displayedSpecies, setDisplayedSpecies] = useState(["dog", "cat"]);
  const [newPetName, setNewPetName] = useState("");
  const [newPetSpecies, setNewPetSpecies] = useState("dog");

  const handleClickDogsOnlyButton = () => {
    setDisplayedSpecies(["dog"]);
  };
  const handleClickCatsOnlyButton = () => {
    setDisplayedSpecies(["cat"]);
  };
  const handleClickAllSpeciesButton = () => {
    setDisplayedSpecies(["dog", "cat"]);
  };

  const handleChangenewPetName = (event) => {
    setNewPetName(event.target.value);
  };
  const handleChangeInputPetSpecies = (event) => {
    setNewPetSpecies(event.target.value);
  };
  const handleSubmitNewPet = (event) => {
    event.preventDefault();

    if (newPetName) {
      setPets(pets.concat([{ name: newPetName, species: newPetSpecies }]));
      setNewPetName("");
      setNewPetSpecies("dog");
    } else {
      alert("Name is blank.");
    }
  };

  return (
    <>
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Species</th>
          </tr>
        </thead>
        <tbody>
          {pets
            .filter((pet) => displayedSpecies.includes(pet.species))
            .map((pet) => (
              <tr key={`${pet.name}-${pet.species}`}>
                <td>{pet.name}</td>
                <td>{pet.species}</td>
              </tr>
            ))}
        </tbody>
      </table>
      <p>Register New Pet:</p>
      <form onSubmit={handleSubmitNewPet}>
        <label>
          Name:
          <input value={newPetName} onChange={handleChangenewPetName} />
        </label>
        <label>
          Species:
          <select value={newPetSpecies} onChange={handleChangeInputPetSpecies}>
            <option value="dog">Dog</option>
            <option value="cat">Cat</option>
          </select>
        </label>
        <input type="submit" value="submit" />
      </form>
      <button onClick={handleClickDogsOnlyButton}>Show dogs only</button>
      <button onClick={handleClickCatsOnlyButton}>Show cats only</button>
      <button onClick={handleClickAllSpeciesButton}>Show all species</button>
    </>
  );
};

export default PetsPage;
