#pragma once
#include <vector>
#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <string>
#include <map>
#include <iostream>

#include "marching_cubes/marching_cubes_tables.h"

namespace marching_cubes
{

    struct vertex
    {
        glm::vec3 position;
        glm::vec3 normal;
        glm::vec2 texcoord;
    };

    struct Mesh
    {
        std::vector<vertex> vertces;
        std::vector<unsigned int> indices;
    };

    class MarchingCubesChunk
    {
    public:
        int width;               // Width of the terrain grid
        int height;              // Height of the terrain grid
        int depth;               // Depth of the terrain grid
        float isoLevel;          // Iso-surface threshold value
        std::vector<float> grid; // 3D grid of scalar values
        std::vector<unsigned char> typesGrid;
        bool changed = false;
        std::vector<void (*)(MarchingCubesChunk *)> callWenDelete;

        MarchingCubesChunk() {}

        MarchingCubesChunk(int width, int height, int depth, float isoLevel)
        {
            this->width = width;
            this->height = height;
            this->depth = depth;
            this->isoLevel = isoLevel;
            int size = width * height * depth;
            grid.resize(size);
            typesGrid.resize(size);
        }

        // Get the density value at grid point (x, y, z)
        float getDensity(int x, int y, int z) const
        {

            if (x < 0 || x > width - 1 || y < 0 || y > height - 1 || z < 0 || z > depth - 1)
            {
                return 0;
            }
            else
            {
                return grid[x + y * width + z * width * height];
            }
        }

        // Set the density value at grid point (x, y, z)
        void setDensity(int x, int y, int z, float density)
        {
            grid[x + y * width + z * width * height] = density;
            changed = true;
        }

        unsigned char getType(int x, int y, int z) const
        {
            return typesGrid[x + y * width + z * width * height];
        }

        // Set the density value at grid point (x, y, z)
        void setType(int x, int y, int z, unsigned char type)
        {
            typesGrid[x + y * width + z * width * height] = type;
            changed = true;
        }

        ~MarchingCubesChunk()
        {
            for (int i = 0; i < callWenDelete.size(); i++)
            {
                callWenDelete[i](this);
            }
        }
    };

    glm::vec3 interpolateVertex(float isoLevel, const glm::vec3 &p1, const glm::vec3 &p2, float valP1, float valP2)
    {
        float t = (isoLevel - valP1) / (valP2 - valP1);
        return p1 + t * (p2 - p1);
    }

    glm::vec3 computeNormal(const MarchingCubesChunk &terrain, const glm::vec3 &position)
    {
        glm::vec3 normal(
            terrain.getDensity(position.x + 1, position.y, position.z) - terrain.getDensity(position.x - 1, position.y, position.z),
            terrain.getDensity(position.x, position.y + 1, position.z) - terrain.getDensity(position.x, position.y - 1, position.z),
            terrain.getDensity(position.x, position.y, position.z + 1) - terrain.getDensity(position.x, position.y, position.z - 1));

        return glm::normalize(normal);
    }

    glm::vec2 computeTexcoord(const glm::vec3 &position, const MarchingCubesChunk &terrain)
    {
        return glm::vec2(position.x / terrain.width, position.y / terrain.height);
    }

    Mesh marchingCubesToMesh(const MarchingCubesChunk &terrain)
    {
        Mesh mesh;

        for (int x = 0; x < terrain.width - 1; ++x)
        {
            for (int y = 0; y < terrain.height - 1; ++y)
            {
                for (int z = 0; z < terrain.depth - 1; ++z)
                {
                    glm::ivec3 cube[8] = {
                        {x, y, z},
                        {x + 1, y, z},
                        {x + 1, y + 1, z},
                        {x, y + 1, z},
                        {x, y, z + 1},
                        {x + 1, y, z + 1},
                        {x + 1, y + 1, z + 1},
                        {x, y + 1, z + 1}};

                    int cubeIndex = 0;
                    for (int i = 0; i < 8; ++i)
                    {
                        if (terrain.getDensity(cube[i].x, cube[i].y, cube[i].z) < terrain.isoLevel)
                        {
                            cubeIndex |= 1 << i;
                        }
                    }

                    if (edgeTable[cubeIndex] == 0)
                    {
                        continue;
                    }

                    glm::vec3 vertList[12];
                    if (edgeTable[cubeIndex] & 1)
                    {
                        vertList[0] = interpolateVertex(terrain.isoLevel, glm::vec3(cube[0]), glm::vec3(cube[1]),
                                                        terrain.getDensity(cube[0].x, cube[0].y, cube[0].z),
                                                        terrain.getDensity(cube[1].x, cube[1].y, cube[1].z));
                    }
                    // Interpolate other vertex positions similarly...

                    for (int i = 0; triTable[cubeIndex][i] != -1; i += 3)
                    {
                        for (int j = 0; j < 3; ++j)
                        {
                            int edgeIndex = triTable[cubeIndex][i + j];
                            glm::vec3 position = vertList[edgeIndex];

                            // Compute the normal and texcoord using helper functions
                            glm::vec3 normal = computeNormal(terrain, position);
                            glm::vec2 texcoord = computeTexcoord(position, terrain);

                            vertex vert = {position, normal, texcoord};
                            mesh.vertces.push_back(vert);
                            mesh.indices.push_back(static_cast<unsigned int>(mesh.vertces.size()) - 1);
                        }
                    }
                }
            }
        }

        return mesh;
    }

    int calculateCubeIndex(const MarchingCubesChunk &terrain, int x, int y, int z)
    {
        // cout << "X " << x  << "Y " << y  << "Z " << z << endl;

        int cubeIndex = 0;

        // Determine the state of each vertex within the cube
        float density[8];
        density[0] = terrain.getDensity(x, y, z);
        density[1] = terrain.getDensity(x + 1, y, z);
        density[2] = terrain.getDensity(x + 1, y, z + 1);
        density[3] = terrain.getDensity(x, y, z + 1);
        density[4] = terrain.getDensity(x, y + 1, z);
        density[5] = terrain.getDensity(x + 1, y + 1, z);
        density[6] = terrain.getDensity(x + 1, y + 1, z + 1);
        density[7] = terrain.getDensity(x, y + 1, z + 1);

        // Determine the state of each vertex and update the cubeIndex accordingly
        if (density[0] > terrain.isoLevel)
            cubeIndex |= 1;
        if (density[1] > terrain.isoLevel)
            cubeIndex |= 2;
        if (density[2] > terrain.isoLevel)
            cubeIndex |= 4;
        if (density[3] > terrain.isoLevel)
            cubeIndex |= 8;
        if (density[4] > terrain.isoLevel)
            cubeIndex |= 16;
        if (density[5] > terrain.isoLevel)
            cubeIndex |= 32;
        if (density[6] > terrain.isoLevel)
            cubeIndex |= 64;
        if (density[7] > terrain.isoLevel)
            cubeIndex |= 128;

        return cubeIndex;
    }

    glm::vec3 VertexInterp(float isolevel, glm::vec3 p1, glm::vec3 p2, float valp1, float valp2)
    {
        float mu;
        glm::vec3 p;

        if (glm::abs(isolevel - valp1) < 0.00001)
            return (p1);
        if (glm::abs(isolevel - valp2) < 0.00001)
            return (p2);
        if (glm::abs(valp1 - valp2) < 0.00001)
            return (p1);
        mu = (isolevel - valp1) / (valp2 - valp1);
        p.x = p1.x + mu * (p2.x - p1.x);
        p.y = p1.y + mu * (p2.y - p1.y);
        p.z = p1.z + mu * (p2.z - p1.z);

        return p;
    }

    std::map<unsigned int, Mesh> marchingCubesToMeshWithTypes(const MarchingCubesChunk &terrain)
    {
        std::map<unsigned int, Mesh> meshes;

        // cout << terrain.depth << " " << terrain.height << " " << terrain.width << endl;

        // Iterate through the cells in the terrain grid
        for (int z = 0; z < terrain.depth - 1; ++z)
        {

            for (int y = 0; y < terrain.height - 1; ++y)
            {
                for (int x = 0; x < terrain.width - 1; ++x)
                {
                    // Calculate the cube index and perform marching cubes algorithm
                    unsigned int cubeIndex = calculateCubeIndex(terrain, x, y, z);
                    vec3 vertList[12];
                    // Code for calculating the cube index and vertList
                    // ...

                    unsigned char type = terrain.getType(x, y, z);

                    // std::cout << "index\n";

                    // Generate the mesh vertices and indices based on the cubeIndex and type
                    for (int i = 0; triTable[cubeIndex][i] != -1; i += 3)
                    {
                        vertex v1, v2, v3;

                        v1.position = vertList[triTable[cubeIndex][i]];
                        v2.position = vertList[triTable[cubeIndex][i + 1]];
                        v3.position = vertList[triTable[cubeIndex][i + 2]];

                        v1.normal = computeNormal(terrain, v1.position);
                        v2.normal = computeNormal(terrain, v2.position);
                        v3.normal = computeNormal(terrain, v3.position);

                        v1.texcoord = computeTexcoord(v1.position, terrain);
                        v2.texcoord = computeTexcoord(v2.position, terrain);
                        v3.texcoord = computeTexcoord(v3.position, terrain);

                        unsigned int index = meshes[type].vertces.size();
                        meshes[type].vertces.push_back(v1);
                        meshes[type].vertces.push_back(v2);
                        meshes[type].vertces.push_back(v3);

                        meshes[type].indices.push_back(index);
                        meshes[type].indices.push_back(index + 1);
                        meshes[type].indices.push_back(index + 2);

                        // cout << v1.position.x << v1.position.y << v1.position.z << endl;
                        // cout << v2.position.x << v2.position.y << v2.position.z << endl;
                        // cout << v3.position.x << v3.position.y << v3.position.z << endl;
                    }
                }
            }
        }

        return meshes;
    }

    class MarchingCubesMap
    {
    public:
        int width;
        int height;
        int depth;
        int chunkWidth;
        int chunkHeight;
        int chunkDepth;
        std::vector<MarchingCubesChunk> grid = {};
        MarchingCubesMap() {}
        MarchingCubesMap(int width, int height, int depth, int chunkWidth, int chunkHeight, int chunkDepth)
        {
            this->width = width;
            this->height = height;
            this->depth = depth;
            this->chunkWidth = chunkWidth;
            this->chunkHeight = chunkHeight;
            this->chunkDepth = chunkDepth;
            int size = width * height * depth;
            grid.resize(size);
            for (int i = 0; i < size; i++)
            {
                grid[i] = MarchingCubesChunk(chunkWidth, chunkHeight, chunkDepth, 1.0);
            }
        }

        MarchingCubesChunk *getChunk(int x, int y, int z)
        {
            return &grid[x + y * width + z * width * height];
        }

        void setChunk(int x, int y, int z, MarchingCubesChunk chunk)
        {
            grid[x + y * width + z * width * height] = chunk;
        }

        float getDensity(int x, int y, int z)
        {
            int chunkX = x / chunkWidth;
            int chunkY = y / chunkHeight;
            int chunkZ = z / chunkDepth;
            int localX = x % chunkWidth;
            int localY = y % chunkHeight;
            int localZ = z % chunkDepth;

            return getChunk(chunkX, chunkY, chunkZ)->getDensity(localX, localY, localZ);
        }

        void setDensity(int x, int y, int z, float density)
        {
            int chunkX = x / chunkWidth;
            int chunkY = y / chunkHeight;
            int chunkZ = z / chunkDepth;
            int localX = x % chunkWidth;
            int localY = y % chunkHeight;
            int localZ = z % chunkDepth;

            getChunk(chunkX, chunkY, chunkZ)->setDensity(localX, localY, localZ, density);
        }

        unsigned char getType(int x, int y, int z)
        {
            int chunkX = x / chunkWidth;
            int chunkY = y / chunkHeight;
            int chunkZ = z / chunkDepth;
            int localX = x % chunkWidth;
            int localY = y % chunkHeight;
            int localZ = z % chunkDepth;

            return getChunk(chunkX, chunkY, chunkZ)->getType(localX, localY, localZ);
        }

        // Set the density value at grid point (x, y, z)
        void setType(int x, int y, int z, unsigned char type)
        {
            int chunkX = x / chunkWidth;
            int chunkY = y / chunkHeight;
            int chunkZ = z / chunkDepth;
            int localX = x % chunkWidth;
            int localY = y % chunkHeight;
            int localZ = z % chunkDepth;

            getChunk(chunkX, chunkY, chunkZ)->setType(localX, localY, localZ, type);
        }

        void setBorderDensity(int x, int y, int z, float density)
        {
            int chunkX = x / chunkWidth;
            int chunkY = y / chunkHeight;
            int chunkZ = z / chunkDepth;
            int localX = x % chunkWidth;
            int localY = y % chunkHeight;
            int localZ = z % chunkDepth;

            setDensity(x, y, z, density);

            if (localX == 0 && chunkX > 0)
            {
                setDensity(x - 1, y, z, density);
            }
            if (localX == chunkWidth - 1 && chunkX < width / chunkWidth - 1)
            {
                setDensity(x + 1, y, z, density);
            }

            if (localY == 0 && chunkY > 0)
            {
                setDensity(x, y - 1, z, density);
            }
            if (localY == chunkHeight - 1 && chunkY < height / chunkHeight - 1)
            {
                setDensity(x, y + 1, z, density);
            }

            if (localZ == 0 && chunkZ > 0)
            {
                setDensity(x, y, z - 1, density);
            }
            if (localZ == chunkDepth - 1 && chunkZ < height / chunkDepth - 1)
            {
                setDensity(x, y, z + 1, density);
            }
        }

        void setBorderType(int x, int y, int z, char type)
        {
            int chunkX = x / chunkWidth;
            int chunkY = y / chunkHeight;
            int chunkZ = z / chunkDepth;
            int localX = x % chunkWidth;
            int localY = y % chunkHeight;
            int localZ = z % chunkDepth;

            setType(x, y, z, type);

            if (localX == 0 && chunkX > 0)
            {
                setType(x - 1, y, z, type);
            }
            if (localX == chunkWidth - 1 && chunkX < width / chunkWidth - 1)
            {
                setType(x + 1, y, z, type);
            }

            if (localY == 0 && chunkY > 0)
            {
                setType(x, y - 1, z, type);
            }
            if (localY == chunkHeight - 1 && chunkY < height / chunkHeight - 1)
            {
                setType(x, y + 1, z, type);
            }

            if (localZ == 0 && chunkZ > 0)
            {
                setType(x, y, z - 1, type);
            }
            if (localZ == chunkDepth - 1 && chunkZ < height / chunkDepth - 1)
            {
                setType(x, y, z + 1, type);
            }
        }
    };

    /*
    this classe located in MarchingCubesChunk.h
    "class MarchingCubesChunk
    {
    public:
        int width;
        int height;
        int depth;
        float isoLevel;
        std::vector<float> grid;
        MarchingCubesChunk(int width, int height, int depth, float isoLevel);
        float getDensity(int x, int y, int z);
        void setDensity(int x, int y, int z, float density);
    };"
    and this class located in MarchingCubesMap.h "class MarchingCubesMap
    {
    public:
        int width;
        int height;
        int depth;
        int chunkWidth;
        int chunkHeight;
        int chunkDepth;
        std::vector<MarchingCubesChunk> grid;
        MarchingCubesMap(int width, int height, int depth, int chunkWidth, int chunkHeight, int chunkDepth);
        float getDensity(int x, int y, int z);
        void setDensity(int x, int y, int z, float density);
        void setBorderDensity(int x, int y, int z, float density);

    };"
    make the functions setBorderDensity and declare then out of the class from MarchingCubesMap i want that this functions get or set the densitys or types in MarchingCubesChunks relative to the global space and if the density is set on the border of an chunch like the end of one axis the function will set the same value in the begin this axis in the next or previous
    */

};