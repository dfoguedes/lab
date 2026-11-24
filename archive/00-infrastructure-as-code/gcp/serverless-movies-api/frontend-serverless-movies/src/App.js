import React,{useState,useEffect} from 'react';
import './App.css';

function App() {
  const [data,setData]=useState([]);
  const [searchMovie, setSearchMovie] = useState('')
  const getData=()=>{
    fetch('https://us-central1-resolute-ascent-429512-h0.cloudfunctions.net/get_movies'
    ,{
      headers : { 
        'Content-Type': 'application/json',
        'Accept': 'application/json'
       }
    }
    )
      .then(function(response){
        console.log(response)
        return response.json();
      })
      .then(function(myJson) {
        console.log(myJson);
        setData(myJson)
      });
  }
  useEffect(()=>{
    getData()
  },[]);

  const filterMovies = data.filter((movie) =>  
    movie.release_year.toLowerCase().includes(searchMovie.toLowerCase()))

  return (
    <div className="App">
      <h1>Favorite movies</h1>
       {/* Search box */}
       <input
        type="text"
        placeholder="Search for a movie by its release year..."
        value={searchMovie}
        onChange={(e) => setSearchMovie(e.target.value)} // Update search term as user types
        className="search-box"
      />
     {
     
        filterMovies.length > 0 && filterMovies.map((item, index) => (
        <div key={index} className='movie-card'>
          <p className='movie-title'>Movie name: {item.title}</p>
          <p className='movie-details'>Genre: {item.genre}</p>
          <p className='movie-details'>Rating: {item.rating}</p>
          <p className='movie-details'>Release year: {item.release_year}</p>
          <p className='movie-details'>Director: {item.director}</p>
          <img src={item.image_url}/>
        </div>
      ))
     }
     </div>
  );
}

export default App;